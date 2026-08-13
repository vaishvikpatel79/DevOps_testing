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

resource "google_project_service" "enable_compute_api" {
  service = "compute.googleapis.com"
}

resource "google_project_service" "enable_run_api" {
  service = "run.googleapis.com"
}

resource "google_project_service" "enable_vpcaccess_api" {
  service = "vpcaccess.googleapis.com"
}

resource "google_project_service" "enable_logging_api" {
  service = "logging.googleapis.com"
}

resource "google_compute_network" "fastapi_demo_vpc" {
  name                    = "${var.project_name}-${var.environment}-vpc"
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"

  depends_on = [google_project_service.enable_compute_api]
}

resource "google_compute_subnetwork" "app_subnet" {
  name          = "${var.project_name}-${var.environment}-app-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.fastapi_demo_vpc.id

  depends_on = [google_compute_network.fastapi_demo_vpc]
}

resource "google_vpc_access_connector" "fastapi_demo_connector" {
  name = "${var.project_name}-${var.environment}-connector"

  subnet {
    name = google_compute_subnetwork.app_subnet.name
  }

  depends_on = [google_project_service.enable_vpcaccess_api, google_compute_subnetwork.app_subnet]
}

resource "google_service_account" "fastapi_demo_run_sa" {
  account_id   = var.service_account_id
  display_name = "${var.project_name}-${var.environment}-run-sa"
  depends_on   = [google_project_service.enable_run_api]
}

resource "google_project_iam_member" "sa_logging_writer" {
  member     = "serviceAccount:${google_service_account.fastapi_demo_run_sa.email}"
  role       = "roles/logging.logWriter"
  project    = var.project_id
  depends_on = [google_service_account.fastapi_demo_run_sa, google_project_service.enable_logging_api]
}

resource "google_cloud_run_service" "fastapi_demo_service" {
  name     = "${var.project_name}-${var.environment}-crsvc"
  location = var.region

  metadata {
    annotations = {
      "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.fastapi_demo_connector.name
      "run.googleapis.com/launch-stage"         = "GA"
    }
    labels = {
      environment = var.environment
      project     = var.project_name
      managed_by  = "terraform"
    }
  }

  template {
    metadata {
      labels = {
        environment = var.environment
        project     = var.project_name
        managed_by  = "terraform"
      }
    }

    spec {
      service_account_name = google_service_account.fastapi_demo_run_sa.email

      containers {
        image = local.service_images["fastapi-demo-service"]

        ports {
          container_port = 8000
        }

        resources {
          requests = {
            cpu    = "1"
            memory = "512Mi"
          }
        }

        liveness_probe {
          period_seconds = 30
          http_get {
            path = "/health"
          }
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [google_project_service.enable_run_api, google_vpc_access_connector.fastapi_demo_connector, google_service_account.fastapi_demo_run_sa, google_project_iam_member.sa_logging_writer]
}

resource "google_cloud_run_service_iam_member" "fastapi_demo_service_public_invoker" {
  service    = google_cloud_run_service.fastapi_demo_service.name
  role       = "roles/run.invoker"
  member     = "allUsers"
  project    = var.project_id
  depends_on = [google_cloud_run_service.fastapi_demo_service]
}

resource "google_compute_region_network_endpoint_group" "fastapi_demo_serverless_neg" {
  name    = "${var.project_name}-${var.environment}-neg"
  region  = var.region
  network = google_compute_network.fastapi_demo_vpc.id

  cloud_run {
    service = google_cloud_run_service.fastapi_demo_service.name
  }

  depends_on = [google_cloud_run_service.fastapi_demo_service, google_project_service.enable_compute_api]
}

resource "google_compute_backend_service" "fastapi_demo_backend" {
  name                  = "${var.project_name}-${var.environment}-backend"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  health_checks         = [google_compute_health_check.fastapi_demo_health_check.id]

  backend {
    group = google_compute_region_network_endpoint_group.fastapi_demo_serverless_neg.id
  }

  depends_on = [google_compute_region_network_endpoint_group.fastapi_demo_serverless_neg, google_project_service.enable_compute_api]
}

resource "google_compute_url_map" "fastapi_demo_url_map" {
  name            = "${var.project_name}-${var.environment}-urlmap"
  default_service = google_compute_backend_service.fastapi_demo_backend.id

  depends_on = [google_compute_backend_service.fastapi_demo_backend]
}

resource "google_compute_target_http_proxy" "fastapi_demo_http_proxy" {
  name    = "${var.project_name}-${var.environment}-http-proxy"
  url_map = google_compute_url_map.fastapi_demo_url_map.id

  depends_on = [google_compute_url_map.fastapi_demo_url_map]
}

resource "google_compute_global_address" "fastapi_demo_lb_ip" {
  name = "${var.project_name}-${var.environment}-lb-ip"

  labels = {
    environment = var.environment
    project     = var.project_name
    managed_by  = "terraform"
  }

  depends_on = [google_project_service.enable_compute_api]
}

resource "google_compute_global_forwarding_rule" "fastapi_demo_forwarding_rule" {
  name                  = "${var.project_name}-${var.environment}-fw-rule"
  target                = google_compute_target_http_proxy.fastapi_demo_http_proxy.id
  port_range            = "80"
  ip_address            = google_compute_global_address.fastapi_demo_lb_ip.address
  load_balancing_scheme = "EXTERNAL_MANAGED"

  depends_on = [google_compute_target_http_proxy.fastapi_demo_http_proxy, google_compute_global_address.fastapi_demo_lb_ip]
}
