output "vpc_self_link" {
  description = "Self link of the VPC network"
  value       = google_compute_network.fastapi_demo_vpc.self_link
}

output "subnet_self_link" {
  description = "Self link of the app subnetwork"
  value       = google_compute_subnetwork.app_subnet.self_link
}

output "vpc_connector_name" {
  description = "Serverless VPC Access connector name"
  value       = google_vpc_access_connector.vpc_connector.name
}

output "service_account_email" {
  description = "Email of the Cloud Run service account"
  value       = google_service_account.fastapi_demo_run_sa.email
}

output "cloud_run_service_name" {
  description = "Cloud Run service name"
  value       = google_cloud_run_service.fastapi_demo_service.name
}

output "cloud_run_service_url" {
  description = "Cloud Run service URL"
  value       = try(google_cloud_run_service.fastapi_demo_service.status[0].url, null)
}

output "backend_service_self_link" {
  description = "Self link of the backend service"
  value       = google_compute_backend_service.fastapi_demo_backend.self_link
}

output "load_balancer_ip" {
  description = "Reserved global IP for the application load balancer"
  value       = google_compute_global_address.fastapi_demo_lb_ip.address
}

output "forwarding_rule_self_link" {
  description = "Global forwarding rule self link"
  value       = google_compute_global_forwarding_rule.fastapi_demo_forwarding_rule.self_link
}

output "deployment_contract" {
  description = "Canonical deployment contract for the deployment agent"
  value = {
    meta = {
      contract_version = "1.0"
      cloud = "google"
      runtime = "cloud_run"
      application_type = "Backend-only app"
      environment = var.environment
      region = var.region
      deployment_type = "serverless"
    }

    compute = {
      cluster_name = null
      service_name = google_cloud_run_service.fastapi_demo_service.name
      service_names = {
        (var.cloud_run_service_name) = google_cloud_run_service.fastapi_demo_service.name
      }
      task_family = null
      workload_name = null
    }

    network = {
      vpc_id = google_compute_network.fastapi_demo_vpc.self_link
      subnet_ids = [google_compute_subnetwork.app_subnet.self_link]
      security_group_ids = [google_compute_firewall.fastapi_demo_lb_firewall.name, google_compute_firewall.fastapi_demo_backend_firewall.name]
      ingress_id = google_compute_global_forwarding_rule.fastapi_demo_forwarding_rule.self_link
    }

    routing = {
      public_endpoint = try(google_cloud_run_service.fastapi_demo_service.status[0].url, null)
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
        logging = google_project_iam_member.fastapi_demo_run_sa_logging_binding.role
      }
    }

    health = {
      frontend_path = null
      backend_path = var.health_path
      readiness_path = null
      liveness_path = var.health_path
    }
  }
}
