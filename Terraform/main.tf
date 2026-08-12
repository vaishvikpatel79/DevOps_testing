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

resource "google_compute_network" "fastapi_demo_vpc" {
  name                    = "${var.project_name}-${var.environment}-vpc"
  auto_create_subnetworks = false

  params {
    resource_manager_tags = {
      environment = var.environment
      project     = var.project_name
      managed_by  = "terraform"
    }
  }
}

resource "google_compute_subnetwork" "app_subnet" {
  name          = "${var.project_name}-${var.environment}-subnet"
  region        = var.region
  network       = google_compute_network.fastapi_demo_vpc.self_link
  ip_cidr_range = var.subnet_cidr

  params {
    resource_manager_tags = {
      environment = var.environment
      project     = var.project_name
      managed_by  = "terraform"
    }
  }
}

resource "google_vpc_access_connector" "vpc_connector" {
  name          = "${var.project_name}-${var.environment}-connector"
  region        = var.region
  ip_cidr_range = var.vpc_connector_ip_cidr

  subnet {
    name = google_compute_subnetwork.app_subnet.name
  }
}

resource "google_service_account" "fastapi_demo_run_sa" {
  account_id   = var.service_account_name
  display_name = "${var.project_name}-${var.environment}-run-sa"
}

resource "google_project_iam_member" "fastapi_demo_run_sa_logging_binding" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.fastapi_demo_run_sa.email}"
}

resource "google_cloud_run_service" "fastapi_demo_service" {
  location                   = var.region
  name                       = var.cloud_run_service_name
  autogenerate_revision_name = true

  metadata {
    annotations = {
      "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.vpc_connector.name
      "run.googleapis.com/vpc-access-egress"    = "all"
      "run.googleapis.com/client-name"          = "terraform"
      "run.googleapis.com/service-account"      = google_service_account.fastapi_demo_run_sa.email
    }
    labels = {
      environment = var.environment
      project     = var.project_name
      managed_by  = "terraform"
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
            path = var.health_path
          }
          period_seconds = var.health_check_interval
        }
      }
    }
  }

  traffic {
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_member" "fastapi_demo_service_invoker_allusers" {
  service = google_cloud_run_service.fastapi_demo_service.name
  role    = "roles/run.invoker"
  member  = "allUsers"
}

resource "google_compute_region_network_endpoint_group" "fastapi_demo_serverless_neg" {
  name   = "${var.project_name}-${var.environment}-neg"
  region = var.region

  cloud_run {
    service = google_cloud_run_service.fastapi_demo_service.name
  }
}

resource "google_compute_backend_service" "fastapi_demo_backend" {
  name                 = "${var.project_name}-${var.environment}-backend"
  load_balancing_scheme = "EXTERNAL"
  protocol             = "HTTP"

  backend {
    group = google_compute_region_network_endpoint_group.fastapi_demo_serverless_neg.id
  }

  params {
    resource_manager_tags = {
      environment = var.environment
      project     = var.project_name
      managed_by  = "terraform"
    }
  }
}

resource "google_compute_url_map" "fastapi_demo_url_map" {
  name           = "${var.project_name}-${var.environment}-urlmap"
  default_service = google_compute_backend_service.fastapi_demo_backend.self_link

  params {
    resource_manager_tags = {
      environment = var.environment
      project     = var.project_name
      managed_by  = "terraform"
    }
  }
}

resource "google_compute_target_http_proxy" "fastapi_demo_http_proxy" {
  name    = "${var.project_name}-${var.environment}-http-proxy"
  url_map = google_compute_url_map.fastapi_demo_url_map.self_link
}

resource "google_compute_global_address" "fastapi_demo_lb_ip" {
  name         = "${var.project_name}-${var.environment}-lb-ip"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"

  labels = {
    environment = var.environment
    project     = var.project_name
    managed_by  = "terraform"
  }
}

resource "google_compute_global_forwarding_rule" "fastapi_demo_forwarding_rule" {
  name                  = "${var.project_name}-${var.environment}-fwd-rule"
  target                = google_compute_target_http_proxy.fastapi_demo_http_proxy.self_link
  ip_address            = google_compute_global_address.fastapi_demo_lb_ip.address
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL"

  labels = {
    environment = var.environment
    project     = var.project_name
    managed_by  = "terraform"
  }
}

resource "google_compute_firewall" "fastapi_demo_lb_firewall" {
  name    = "${var.project_name}-${var.environment}-lb-fw"
  network = google_compute_network.fastapi_demo_vpc.self_link
  description = "Allow HTTP from internet to load balancer"
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  params {
    resource_manager_tags = {
      environment = var.environment
      project     = var.project_name
      managed_by  = "terraform"
    }
  }
}

resource "google_compute_firewall" "fastapi_demo_backend_firewall" {
  name    = "${var.project_name}-${var.environment}-backend-fw"
  network = google_compute_network.fastapi_demo_vpc.self_link
  description = "Allow traffic from load balancer to backend on 8000"
  source_ranges = [format("%s/32", google_compute_global_address.fastapi_demo_lb_ip.address)]

  allow {
    protocol = "tcp"
    ports    = ["8000"]
  }

  params {
    resource_manager_tags = {
      environment = var.environment
      project     = var.project_name
      managed_by  = "terraform"
    }
  }
}
