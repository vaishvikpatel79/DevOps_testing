output "cloud_run_service_name" {
  description = "Name of the Cloud Run service resource"
  value       = google_cloud_run_service.fastapi_demo_service.name
}

output "cloud_run_service_url" {
  description = "Cloud Run service URL (from resource status)."
  value       = try(google_cloud_run_service.fastapi_demo_service.status[0].url, null)
}

output "load_balancer_ip" {
  description = "Global external IP address for the application load balancer"
  value       = google_compute_global_address.fastapi_demo_lb_ip.address
}

output "backend_service_name" {
  description = "Backend service name"
  value       = google_compute_backend_service.fastapi_demo_backend.name
}

output "serverless_neg_name" {
  description = "Serverless NEG name"
  value       = google_compute_region_network_endpoint_group.fastapi_demo_serverless_neg.name
}

output "vpc_connector_name" {
  description = "Serverless VPC Access connector name"
  value       = google_vpc_access_connector.fastapi_demo_connector.name
}

output "deployment_contract" {
  description = "Standardized deployment contract for the deployment agent"
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
      service_names = { "fastapi-demo-service" = google_cloud_run_service.fastapi_demo_service.name }
      task_family   = null
      workload_name = null
    }

    network = {
      vpc_id             = google_compute_network.fastapi_demo_vpc.id
      subnet_ids         = [google_compute_subnetwork.app_subnet.id]
      security_group_ids = null
      ingress_id         = null
    }

    routing = {
      public_endpoint      = google_compute_global_address.fastapi_demo_lb_ip.address
      internal_endpoint    = null
      custom_domain        = null
      certificate_required = false
      certificate_mode     = null
    }

    data = {
      database_endpoint = null
      cache_endpoint    = null
      object_store_name = null
    }

    security = {
      certificate_ref = null
      secret_refs     = null
      role_arns       = null
    }

    health = {
      frontend_path  = null
      backend_path   = "/health"
      readiness_path = null
      liveness_path  = "/health"
    }
  }
}
