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

# 1. Enable Cloud Run API
resource "google_project_service" "enable_run_api" {
  service = "run.googleapis.com"
}

# 2. Enable Compute API
resource "google_project_service" "enable_compute_api" {
  service = "compute.googleapis.com"
}

# 3. Enable Serverless VPC Access API
resource "google_project_service" "enable_vpcaccess_api" {
  service = "vpcaccess.googleapis.com"
}

# 4. Enable IAM API
resource "google_project_service" "enable_iam_api" {
  service = "iam.googleapis.com"
}

# 5. Enable Logging API
resource "google_project_service" "enable_logging_api" {
  service = "logging.googleapis.com"
}

# 6. VPC Network
resource "google_compute_network" "fastapi-demo-vpc" {
  name                      = "${var.project_name}-${var.environment}-vpc"
  auto_create_subnetworks   = false

  params {
    resource_manager_tags = {
      environment = var.environment
      project     = var.project_name
      managed_by  = var.managed_by
    }
  }

  depends_on = [google_project_service.enable_compute_api]
}

# 7. Service Account for Cloud Run
resource "google_service_account" "fastapi-demo-run-sa" {
  account_id = var.service_account_name
  display_name = "${var.project_name}-${var.environment}-run-sa"

  depends_on = [google_project_service.enable_iam_api]
}

# 8. Subnetwork
resource "google_compute_subnetwork" "app-subnet" {
  name    = "${var.project_name}-${var.environment}-app-subnet"
  ip_cidr_range = var.subnet_cidr
  region  = var.region
  network = google_compute_network.fastapi-demo-vpc.self_link

  labels = {
    environment = var.environment
    project     = var.project_name
    managed_by  = var.managed_by
  }

  depends_on = [google_compute_network.fastapi-demo-vpc, google_project_service.enable_compute_api]
}

# 9. Grant Logging Writer role to the service account
resource "google_project_iam_member" "run-sa-logging-writer" {
  member  = "serviceAccount:${google_service_account.fastapi-demo-run-sa.email}"
  project = var.project_id
  role    = "roles/logging.logWriter"

  depends_on = [google_service_account.fastapi-demo-run-sa, google_project_service.enable_iam_api]
}

# 10. Serverless VPC Access Connector
resource "google_vpc_access_connector" "fastapi-demo-connector" {
  name = "${var.project_name}-${var.environment}-connector"

  subnet {
    name = google_compute_subnetwork.app-subnet.name
  }

  depends_on = [google_compute_subnetwork.app-subnet, google_project_service.enable_vpcaccess_api]
}

# 11. Cloud Run service (Second Generation) configured for internal + CLB ingress and VPC connector
resource "google_cloud_run_service" "fastapi-demo-service" {
  location = var.region
  name     = "${var.project_name}-${var.environment}-service"

  metadata {
    labels = {
      environment = var.environment
      project     = var.project_name
      managed_by  = var.managed_by
    }
    annotations = {
      "run.googleapis.com/ingress" = "internal-and-cloud-load-balancing"
    }
  }

  template {
    spec {
      service_account_name = google_service_account.fastapi-demo-run-sa.email

      vpc_access {
        connector = google_vpc_access_connector.fastapi-demo-connector.name
        egress    = "ALL_TRAFFIC"
      }

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
          http_get {
            path = "/health"
          }
          period_seconds        = 30
        }
      }
    }
  }

  depends_on = [google_project_service.enable_run_api, google_service_account.fastapi-demo-run-sa, google_vpc_access_connector.fastapi-demo-connector]
}

# 12. Allow unauthenticated invocation (public)
resource "google_cloud_run_service_iam_member" "fastapi-demo-service-invoker" {
  service = google_cloud_run_service.fastapi-demo-service.name
  role    = "roles/run.invoker"
  member  = "allUsers"

  depends_on = [google_cloud_run_service.fastapi-demo-service]
}

# 13. Health check
resource "google_compute_health_check" "fastapi-demo-health-check" {
  name = "${var.project_name}-${var.environment}-health-check"

  http_health_check {
    request_path = "/health"
    port         = 8000
  }

  check_interval_sec = 30

  depends_on = [google_project_service.enable_compute_api]
}

# 14. Regional Serverless NEG pointing to Cloud Run
resource "google_compute_region_network_endpoint_group" "fastapi-demo-serverless-neg" {
  name   = "${var.project_name}-${var.environment}-serverless-neg"
  region = var.region

  cloud_run {
    service = google_cloud_run_service.fastapi-demo-service.name
    region  = var.region
  }

  depends_on = [google_cloud_run_service.fastapi-demo-service, google_project_service.enable_compute_api]
}

# 15. Global Backend Service referencing the serverless NEG
resource "google_compute_backend_service" "fastapi-demo-backend" {
  name                 = "${var.project_name}-${var.environment}-backend"
  protocol             = "HTTP"
  load_balancing_scheme = "EXTERNAL"

  backend {
    group = google_compute_region_network_endpoint_group.fastapi-demo-serverless-neg.id
  }

  health_checks = [google_compute_health_check.fastapi-demo-health-check.self_link]

  params {
    resource_manager_tags = {
      environment = var.environment
      project     = var.project_name
      managed_by  = var.managed_by
    }
  }

  depends_on = [google_compute_region_network_endpoint_group.fastapi-demo-serverless-neg, google_compute_health_check.fastapi-demo-health-check, google_project_service.enable_compute_api]
}

# 16. Global static IP for the Load Balancer
resource "google_compute_global_address" "fastapi-demo-lb-ip" {
  name = "${var.project_name}-${var.environment}-lb-ip"
  address_type = "EXTERNAL"
  ip_version = "IPV4"

  labels = {
    environment = var.environment
    project     = var.project_name
    managed_by  = var.managed_by
  }

  depends_on = [google_project_service.enable_compute_api]
}

# 17. URL map forwarding to backend service
resource "google_compute_url_map" "fastapi-demo-url-map" {
  name = "${var.project_name}-${var.environment}-url-map"
  default_service = google_compute_backend_service.fastapi-demo-backend.self_link

  depends_on = [google_compute_backend_service.fastapi-demo-backend]
}

# 18. Target HTTP Proxy
resource "google_compute_target_http_proxy" "fastapi-demo-http-proxy" {
  name    = "${var.project_name}-${var.environment}-http-proxy"
  url_map = google_compute_url_map.fastapi-demo-url-map.self_link

  depends_on = [google_compute_url_map.fastapi-demo-url-map]
}

# 19. Global Forwarding Rule for port 80
resource "google_compute_global_forwarding_rule" "fastapi-demo-forwarding-rule" {
  name                = "${var.project_name}-${var.environment}-forwarding-rule"
  target              = google_compute_target_http_proxy.fastapi-demo-http-proxy.self_link
  ip_address          = google_compute_global_address.fastapi-demo-lb-ip.address
  port_range          = "80"
  load_balancing_scheme = "EXTERNAL"

  labels = {
    environment = var.environment
    project     = var.project_name
    managed_by  = var.managed_by
  }

  depends_on = [google_compute_target_http_proxy.fastapi-demo-http-proxy, google_compute_global_address.fastapi-demo-lb-ip]
}
