locals {
  # Construct full Artifact Registry image URIs for every service from the service_tags map.
  # artifact_registry_repository defaults to var.project_name (e.g. "ecommerce-platform").
  # service_tags = { "app-service" = "v1", ... }
  # Resulting map: { "app-service" = "us-central1-docker.pkg.dev/my-project/ecommerce-platform/app-service:v1", ... }
  service_images = {
    for service_name, tag in var.service_tags :
    service_name => "${var.region}-docker.pkg.dev/${var.project_id}/${var.artifact_registry_repository}/${var.service_repositories[service_name]}:${tag}"
  }
}

# Read existing project
data "google_project" "project" {
  project_id = var.project_id
}

# Enable required APIs
resource "google_project_service" "compute_api" {
  service = "compute.googleapis.com"
  project = var.project_id
  depends_on = [data.google_project.project]
}

resource "google_project_service" "cloud_run_api" {
  service = "run.googleapis.com"
  project = var.project_id
  depends_on = [data.google_project.project]
}

resource "google_project_service" "vpcaccess_api" {
  service = "vpcaccess.googleapis.com"
  project = var.project_id
  depends_on = [data.google_project.project]
}

resource "google_project_service" "logging_api" {
  service = "logging.googleapis.com"
  project = var.project_id
  depends_on = [data.google_project.project]
}

# VPC network
resource "google_compute_network" "fastapi_demo_vpc" {
  name                    = "${var.project_name}-${var.environment}-vpc"
  auto_create_subnetworks = false

  params {
    resource_manager_tags = {
      environment = var.environment
      project     = var.project_name
      managed_by  = var.managed_by
    }
  }

  depends_on = [google_project_service.compute_api]
}

# Subnetwork
resource "google_compute_subnetwork" "app_subnet" {
  name          = "${var.project_name}-${var.environment}-app-subnet"
  region        = var.region
  network       = google_compute_network.fastapi_demo_vpc.self_link
  ip_cidr_range = var.subnet_cidr

  params {
    resource_manager_tags = {
      environment = var.environment
      project     = var.project_name
      managed_by  = var.managed_by
    }
  }

  depends_on = [google_compute_network.fastapi_demo_vpc]
}

# VPC Access Connector for Cloud Run
resource "google_vpc_access_connector" "fastapi_demo_connector" {
  name   = "${var.project_name}-${var.environment}-connector"
  region = var.region

  subnet {
    name = google_compute_subnetwork.app_subnet.name
  }

  depends_on = [google_compute_subnetwork.app_subnet, google_project_service.vpcaccess_api]
}

# Service account for Cloud Run
resource "google_service_account" "fastapi_demo_run_sa" {
  account_id   = var.service_account_id
  display_name = "Cloud Run service account for ${var.project_name}-${var.environment}"
  project      = var.project_id

  depends_on = [data.google_project.project]
}

# Grant Logging Writer role to the service account
resource "google_project_iam_member" "fastapi_logging_binding" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.fastapi_demo_run_sa.email}"

  depends_on = [google_service_account.fastapi_demo_run_sa, google_project_service.logging_api]
}

# Cloud Run service
resource "google_cloud_run_service" "fastapi_demo_service" {
  name     = "${var.project_name}-${var.environment}-service"
  location = var.region

  metadata {
    annotations = {
      "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.fastapi_demo_connector.name
      "run.googleapis.com/vpc-access-egress"    = "all"
      "run.googleapis.com/ingress"              = "internal-and-cloud-load-balancing"
      "autoscaling.knative.dev/minScale"        = tostring(var.min_instances)
      "autoscaling.knative.dev/maxScale"        = tostring(var.max_instances)
    }

    labels = {
      environment = var.environment
      project     = var.project_name
      managed_by  = var.managed_by
    }
  }

  template {
    spec {
      containers {
        image = local.service_images["fastapi-demo-service"]

        ports {
          container_port = var.container_port
        }

        resources {
          requests = {
            cpu    = var.container_cpu
            memory = var.container_memory
          }
        }

        liveness_probe {
          http_get {
            path = var.health_check_path
          }
          period_seconds       = var.health_check_interval_seconds
          timeout_seconds      = 10
          initial_delay_seconds = 0
        }
      }
    }
  }

  depends_on = [google_service_account.fastapi_demo_run_sa, google_vpc_access_connector.fastapi_demo_connector, google_project_service.cloud_run_api]
}

# Allow public (unauthenticated) access to Cloud Run service
resource "google_cloud_run_service_iam_member" "fastapi_demo_invoker_allusers" {
  service = google_cloud_run_service.fastapi_demo_service.name
  role    = "roles/run.invoker"
  member  = "allUsers"

  depends_on = [google_cloud_run_service.fastapi_demo_service]
}

# Serverless NEG pointing at Cloud Run
resource "google_compute_region_network_endpoint_group" "fastapi_serverless_neg" {
  name   = "${var.project_name}-${var.environment}-neg"
  region = var.region

  cloud_run {
    service = google_cloud_run_service.fastapi_demo_service.name
  }

  depends_on = [google_cloud_run_service.fastapi_demo_service, google_project_service.compute_api]
}

# HTTP health check for the load balancer
resource "google_compute_health_check" "fastapi_health_check" {
  name = "${var.project_name}-${var.environment}-hc"

  check_interval_sec   = var.health_check_interval_seconds
  timeout_sec          = 10
  healthy_threshold    = 1
  unhealthy_threshold  = 3

  http_health_check {
    request_path = var.health_check_path
    port         = var.health_check_port
  }

  depends_on = [google_project_service.compute_api]
}

# Global backend service forwarding to the serverless NEG
resource "google_compute_backend_service" "fastapi_demo_backend" {
  name                 = "${var.project_name}-${var.environment}-backend"
  protocol             = "HTTP"
  load_balancing_scheme = "EXTERNAL"

  health_checks = [google_compute_health_check.fastapi_health_check.self_link]

  backend {
    group = google_compute_region_network_endpoint_group.fastapi_serverless_neg.id
  }

  params {
    resource_manager_tags = {
      environment = var.environment
      project     = var.project_name
      managed_by  = var.managed_by
    }
  }

  depends_on = [google_compute_region_network_endpoint_group.fastapi_serverless_neg, google_compute_health_check.fastapi_health_check, google_project_service.compute_api]
}

# URL map routing to backend service
resource "google_compute_url_map" "fastapi_url_map" {
  name           = "${var.project_name}-${var.environment}-url-map"
  default_service = google_compute_backend_service.fastapi_demo_backend.self_link

  depends_on = [google_compute_backend_service.fastapi_demo_backend]
}

# Target HTTP proxy for URL map
resource "google_compute_target_http_proxy" "fastapi_http_proxy" {
  name    = "${var.project_name}-${var.environment}-http-proxy"
  url_map = google_compute_url_map.fastapi_url_map.self_link

  depends_on = [google_compute_url_map.fastapi_url_map]
}

# Global external IP for the load balancer
resource "google_compute_global_address" "fastapi_lb_ip" {
  name         = "${var.project_name}-${var.environment}-lb-ip"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"

  labels = {
    environment = var.environment
    project     = var.project_name
    managed_by  = var.managed_by
  }

  depends_on = [google_project_service.compute_api]
}

# Global forwarding rule listening on port 80 -> target HTTP proxy
resource "google_compute_global_forwarding_rule" "fastapi_http_forwarding_rule" {
  name                 = "${var.project_name}-${var.environment}-http-forward"
  target               = google_compute_target_http_proxy.fastapi_http_proxy.self_link
  ip_address           = google_compute_global_address.fastapi_lb_ip.address
  port_range           = "80-80"
  load_balancing_scheme = "EXTERNAL"

  labels = {
    environment = var.environment
    project     = var.project_name
    managed_by  = var.managed_by
  }

  depends_on = [google_compute_target_http_proxy.fastapi_http_proxy, google_compute_global_address.fastapi_lb_ip]
}
