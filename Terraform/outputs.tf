output "cloud_run_service_name" {
  description = "Cloud Run service resource name"
  value       = google_cloud_run_service.fastapi-demo-service.name
}

output "cloud_run_service_url" {
  description = "Cloud Run service URL"
  value       = try(google_cloud_run_service.fastapi-demo-service.status[0].url, null)
}

output "load_balancer_ip" {
  description = "Reserved global external IP for the application load balancer"
  value       = google_compute_global_address.fastapi-demo-lb-ip.address
}

output "backend_service_name" {
  description = "Backend service name used by the URL map"
  value       = google_compute_backend_service.fastapi-demo-backend.name
}

output "neg_name" {
  description = "Serverless NEG name"
  value       = google_compute_region_network_endpoint_group.fastapi-demo-serverless-neg.name
}

output "health_check_name" {
  description = "Health check name"
  value       = google_compute_health_check.fastapi-demo-health-check.name
}

output "service_account_email" {
  description = "Service account email created for Cloud Run"
  value       = google_service_account.fastapi-demo-run-sa.email
}

output "deployment_contract" {
  description = "Canonical deployment contract for the Deployment Agent"
  value = {
    meta = {
      contract_version = "1.0"
      cloud = "google"
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
        "fastapi-demo-service" = google_cloud_run_service.fastapi-demo-service.name
      }
      task_family = null
      workload_name = null
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
        logging_writer = google_project_iam_member.sa_logging_writer.role
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
