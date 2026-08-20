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

resource "google_project_service" "enable_run_api" {
  service = "run.googleapis.com"
}

resource "google_project_service" "enable_compute_api" {
  service = "compute.googleapis.com"
}

resource "google_project_service" "enable_vpcaccess_api" {
  service = "vpcaccess.googleapis.com"
}

resource "google_project_service" "enable_iam_api" {
  service = "iam.googleapis.com"
}

resource "google_project_service" "enable_logging_api" {
  service = "logging.googleapis.com"
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
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.fastapi_demo_vpc.self_link

  params {
    resource_manager_tags = {
      environment = var.environment
      project     = var.project_name
      managed_by  = "terraform"
    }
  }
}

resource "google_service_account" "fastapi_demo_run_sa" {
  account_id   = "fastapi-demo-run-sa"
  display_name = "${var.project_name}-${var.environment} Cloud Run SA"
}

resource "google_vpc_access_connector" "fastapi_demo_vpc_connector" {
  name = "${var.project_name}-${var.environment}-vpc-connector"

  subnet {
    name = google_compute_subnetwork.app_subnet.name
  }
}

resource "google_cloud_run_service" "fastapi_demo_service" {
  location = var.region
  name     = "${var.project_name}-${var.environment}-service"

  autogenerate_revision_name = true

  metadata {
    labels = {
      environment = var.environment
      project     = var.project_name
      managed_by  = "terraform"
    }
    annotations = {
      "run.googleapis.com/ingress" = "internal-and-cloud-load-balancing"
    }
  }

  template {
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
          http_get {
            path = "/health"
          }
          period_seconds        = 30
          timeout_seconds       = 10
          initial_delay_seconds = 0
        }
      }
    }
  }
}

resource "google_cloud_run_service_iam_member" "fastapi_demo_service_allow_unauthenticated" {
  service = google_cloud_run_service.fastapi_demo_service.name
  role    = "roles/run.invoker"
  member  = "allUsers"
  depends_on = [google_cloud_run_service.fastapi_demo_service]
}

resource "google_project_iam_member" "fastapi_demo_sa_logging_writer" {
  member  = "serviceAccount:${google_service_account.fastapi_demo_run_sa.email}"
  project = var.project_id
  role    = "roles/logging.logWriter"
  depends_on = [google_service_account.fastapi_demo_run_sa, google_project_service.enable_logging_api]
}

resource "google_compute_region_network_endpoint_group" "fastapi_demo_serverless_neg" {
  name   = "${var.project_name}-${var.environment}-neg"
  region = var.region

  cloud_run {
    service = google_cloud_run_service.fastapi_demo_service.name
  }

  depends_on = [google_cloud_run_service.fastapi_demo_service, google_project_service.enable_compute_api]
}

resource "google_compute_health_check" "fastapi_demo_health_check" {
  name = "${var.project_name}-${var.environment}-hc"

  http_health_check {
    request_path = "/health"
    port         = 8000
  }

  check_interval_sec  = 30
  timeout_sec         = 10
  healthy_threshold   = 1
  unhealthy_threshold = 3
}

resource "google_compute_backend_service" "fastapi_demo_backend_service" {
  name = "${var.project_name}-${var.environment}-backend"

  protocol = "HTTP"
  load_balancing_scheme = "EXTERNAL"

  backend {
    group = google_compute_region_network_endpoint_group.fastapi_demo_serverless_neg.id
  }

  health_checks = [google_compute_health_check.fastapi_demo_health_check.self_link]
  depends_on = [google_compute_region_network_endpoint_group.fastapi_demo_serverless_neg, google_compute_health_check.fastapi_demo_health_check, google_project_service.enable_compute_api]
}

resource "google_compute_url_map" "fastapi_demo_url_map" {
  name = "${var.project_name}-${var.environment}-urlmap"

  default_service = google_compute_backend_service.fastapi_demo_backend_service.self_link
  depends_on = [google_compute_backend_service.fastapi_demo_backend_service, google_project_service.enable_compute_api]
}

resource "google_compute_target_http_proxy" "fastapi_demo_http_proxy" {
  name    = "${var.project_name}-${var.environment}-httpproxy"
  url_map = google_compute_url_map.fastapi_demo_url_map.self_link
  depends_on = [google_compute_url_map.fastapi_demo_url_map, google_project_service.enable_compute_api]
}

resource "google_compute_global_address" "fastapi_demo_lb_ip" {
  name = "${var.project_name}-${var.environment}-lb-ip"

  address_type = "EXTERNAL"
  ip_version   = "IPV4"

  labels = {
    environment = var.environment
    project     = var.project_name
    managed_by  = "terraform"
  }
}

resource "google_compute_global_forwarding_rule" "fastapi_demo_forwarding_rule" {
  name = "${var.project_name}-${var.environment}-fwd"

  target     = google_compute_target_http_proxy.fastapi_demo_http_proxy.self_link
  ip_address = google_compute_global_address.fastapi_demo_lb_ip.address
  port_range = "80"
  load_balancing_scheme = "EXTERNAL"
  depends_on = [google_compute_target_http_proxy.fastapi_demo_http_proxy, google_compute_global_address.fastapi_demo_lb_ip, google_project_service.enable_compute_api]
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

  description = "Allow traffic from Google Load Balancers to backend Cloud Run (via NEG)"
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]

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
  depends_on = [google_compute_firewall.fastapi_demo_lb_firewall, google_compute_network.fastapi_demo_vpc]
}
