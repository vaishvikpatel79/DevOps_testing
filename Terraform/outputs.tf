output "cloud_run_service_name" {
  description = "Name of the Cloud Run service"
  value       = google_cloud_run_service.fastapi_demo_service.name
}

output "cloud_run_service_url" {
  description = "URL of the Cloud Run service"
  value       = try(google_cloud_run_service.fastapi_demo_service.status[0].url, null)
}

output "application_load_balancer_ip" {
  description = "Global external IP address for the Application Load Balancer"
  value       = google_compute_global_address.fastapi_lb_ip.address
}

output "backend_service_self_link" {
  description = "Self link of the backend service"
  value       = google_compute_backend_service.fastapi_demo_backend.self_link
}

output "deployment_contract" {
  description = "Canonical deployment contract for the Deployment Agent"
  value = {
    meta = {
      contract_version = "1.0"
      cloud            = "google"
      runtime          = "cloud_run"
      application_type = "backend-only"
      environment      = var.environment
      region           = var.region
      deployment_type  = "serverless"
    }

    compute = {
      cluster_name  = null
      service_name  = google_cloud_run_service.fastapi_demo_service.name
      service_names = { "fastapi-demo-service" = local.service_images["fastapi-demo-service"] }
      task_family   = null
      workload_name = google_cloud_run_service.fastapi_demo_service.name
    }

    network = {
      vpc_id              = google_compute_network.fastapi_demo_vpc.self_link
      subnet_ids          = [google_compute_subnetwork.app_subnet.self_link]
      security_group_ids  = null
      ingress_id          = null
    }

    routing = {
      public_endpoint        = google_compute_global_address.fastapi_lb_ip.address
      internal_endpoint      = null
      custom_domain          = null
      certificate_required   = false
      certificate_mode       = null
    }

    data = {
      database_endpoint   = null
      cache_endpoint      = null
      object_store_name   = null
    }

    security = {
      certificate_ref = null
      secret_refs     = null
      role_arns       = { "cloud_run_service_account" = google_service_account.fastapi_demo_run_sa.email }
    }

    health = {
      frontend_path   = null
      backend_path    = var.health_check_path
      readiness_path  = null
      liveness_path   = var.health_check_path
    }
  }
}
