output "cloud_run_service_name" {
  description = "Cloud Run service resource name"
  value       = google_cloud_run_service.fastapi-demo-service.name
}

output "cloud_run_service_url" {
  description = "Cloud Run service URL"
  value       = try(google_cloud_run_service.fastapi-demo-service.status[0].url, null)
}

output "load_balancer_ip" {
  description = "Global IP address allocated for the external application load balancer"
  value       = google_compute_global_address.fastapi-demo-lb-ip.address
}

output "vpc_self_link" {
  description = "VPC self_link"
  value       = google_compute_network.fastapi-demo-vpc.self_link
}

output "subnet_self_link" {
  description = "Subnetwork self_link"
  value       = google_compute_subnetwork.app-subnet.self_link
}

output "service_account_email" {
  description = "Email of the Cloud Run service account"
  value       = google_service_account.fastapi-demo-run-sa.email
}

output "service_images" {
  description = "Map of service -> full image URI constructed from service_tags"
  value       = local.service_images
}

output "deployment_contract" {
  description = "Canonical deployment contract for the Deployment Agent"
  value = {
    meta = {
      contract_version = "1.0"
      cloud = "gcp"
      runtime = "cloud_run"
      application_type = "backend"
      environment = var.environment
      region = var.region
      deployment_type = "serverless"
    }

    compute = {
      cluster_name = null
      service_name = google_cloud_run_service.fastapi-demo-service.name
      service_names = {
        "fastapi-demo-service" = local.service_images["fastapi-demo-service"]
      }
      task_family = null
      workload_name = google_cloud_run_service.fastapi-demo-service.name
    }

    network = {
      vpc_id = google_compute_network.fastapi-demo-vpc.self_link
      subnet_ids = [google_compute_subnetwork.app-subnet.self_link]
      security_group_ids = null
      ingress_id = null
    }

    routing = {
      public_endpoint = try(google_cloud_run_service.fastapi-demo-service.status[0].url, null)
      internal_endpoint = null
      custom_domain = null
      certificate_required = false
      certificate_mode = null
    }

    data = {
      database_endpoint = null
      cache_endpoint = null
      object_store_name = null
    }

    security = {
      certificate_ref = null
      secret_refs = null
      role_arns = {
        run_service_account = google_service_account.fastapi-demo-run-sa.email
      }
    }

    health = {
      frontend_path = null
      backend_path = "/health"
      readiness_path = null
      liveness_path = "/health"
    }
  }
}
