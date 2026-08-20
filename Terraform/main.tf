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

resource "google_project_service" "run_api" {
  service = "run.googleapis.com"
}

resource "google_project_service" "compute_api" {
  service = "compute.googleapis.com"
}

resource "google_project_service" "vpcaccess_api" {
  service = "vpcaccess.googleapis.com"
}

resource "google_project_service" "iam_api" {
  service = "iam.googleapis.com"
}

resource "google_project_service" "logging_api" {
  service = "logging.googleapis.com"
}

resource "google_compute_network" "fastapi-demo-vpc" {
  name                    = "${var.project_name}-${var.environment}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "app-subnet" {
  name          = "${var.project_name}-${var.environment}-app-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.fastapi-demo-vpc.self_link
  depends_on    = [google_compute_network.fastapi-demo-vpc, google_project_service.compute_api]
}

resource "google_service_account" "fastapi-demo-run-sa" {
  account_id   = var.service_account_name
  display_name = "${var.project_name}-${var.environment}-run-sa"
  depends_on   = [google_project_service.iam_api]
}

resource "google_project_iam_member" "sa_logging_writer" {
  member  = "serviceAccount:${google_service_account.fastapi-demo-run-sa.email}"
  project = var.project_id
  role    = "roles/logging.logWriter"
  depends_on = [google_service_account.fastapi-demo-run-sa, google_project_service.logging_api]
}

resource "google_vpc_access_connector" "fastapi-demo-connector" {
  name = "${var.project_name}-${var.environment}-connector"

  subnet {
    name = google_compute_subnetwork.app-subnet.name
  }

  depends_on = [google_compute_network.fastapi-demo-vpc, google_compute_subnetwork.app-subnet, google_project_service.vpcaccess_api]
}

resource "google_cloud_run_service" "fastapi-demo-service" {
  location = var.region
  name     = "${var.project_name}-${var.environment}-service"

  metadata {
    labels = {
      environment = var.environment
      project     = var.project_name
      managed_by  = "terraform"
    }
    annotations = {
      "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.fastapi-demo-connector.name
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
            path = "/health"
          }
          period_seconds        = 30
          timeout_seconds       = 5
          initial_delay_seconds = 0
        }
      }
    }
  }

  depends_on = [google_project_service.run_api, google_service_account.fastapi-demo-run-sa, google_vpc_access_connector.fastapi-demo-connector]
}

resource "google_cloud_run_service_iam_member" "fastapi-demo-service-invoker-allUsers" {
  service = google_cloud_run_service.fastapi-demo-service.name
  role    = "roles/run.invoker"
  member  = "allUsers"

  depends_on = [google_cloud_run_service.fastapi-demo-service]
}

resource "google_compute_region_network_endpoint_group" "fastapi-demo-serverless-neg" {
  name   = "${var.project_name}-${var.environment}-serverless-neg"
  region = var.region

  cloud_run {
    service = google_cloud_run_service.fastapi-demo-service.name
  }

  depends_on = [google_cloud_run_service.fastapi-demo-service, google_project_service.compute_api]
}

resource "google_compute_health_check" "fastapi-demo-health-check" {
  name = "${var.project_name}-${var.environment}-health-check"

  http_health_check {
    request_path = "/health"
    port         = var.container_port
  }

  check_interval_sec = 30
  depends_on         = [google_project_service.compute_api]
}

resource "google_compute_backend_service" "fastapi-demo-backend" {
  name               = "${var.project_name}-${var.environment}-backend"
  protocol           = "HTTP"
  load_balancing_scheme = "EXTERNAL"

  backend {
    group = google_compute_region_network_endpoint_group.fastapi-demo-serverless-neg.self_link
  }

  health_checks = [google_compute_health_check.fastapi-demo-health-check.self_link]

  depends_on = [google_compute_region_network_endpoint_group.fastapi-demo-serverless-neg, google_compute_health_check.fastapi-demo-health-check, google_project_service.compute_api]
}

resource "google_compute_url_map" "fastapi-demo-url-map" {
  name = "${var.project_name}-${var.environment}-url-map"

  default_service = google_compute_backend_service.fastapi-demo-backend.self_link

  depends_on = [google_compute_backend_service.fastapi-demo-backend]
}

resource "google_compute_target_http_proxy" "fastapi-demo-http-proxy" {
  name    = "${var.project_name}-${var.environment}-http-proxy"
  url_map = google_compute_url_map.fastapi-demo-url-map.self_link

  depends_on = [google_compute_url_map.fastapi-demo-url-map]
}

resource "google_compute_global_address" "fastapi-demo-lb-ip" {
  name      = "${var.project_name}-${var.environment}-lb-ip"
  ip_version = "IPV4"

  labels = {
    environment = var.environment
    project     = var.project_name
    managed_by  = "terraform"
  }

  depends_on = [google_project_service.compute_api]
}

resource "google_compute_global_forwarding_rule" "fastapi-demo-forwarding-rule" {
  name   = "${var.project_name}-${var.environment}-forwarding-rule"
  target = google_compute_target_http_proxy.fastapi-demo-http-proxy.self_link
  ip_address = google_compute_global_address.fastapi-demo-lb-ip.address
  port_range = "80-80"
  load_balancing_scheme = "EXTERNAL"

  labels = {
    environment = var.environment
    project     = var.project_name
    managed_by  = "terraform"
  }

  depends_on = [google_compute_global_address.fastapi-demo-lb-ip, google_compute_target_http_proxy.fastapi-demo-http-proxy]
}
