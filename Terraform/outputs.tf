output "application_load_balancer_ip" {
  description = "Reserved global IP address for the application's external load balancer"
  value       = google_compute_global_address.fastapi_demo_lb_ip.address
}

output "cloud_run_service_name" {
  description = "Cloud Run service resource name"
  value       = google_cloud_run_service.fastapi_demo_service.name
}

output "cloud_run_service_url" {
  description = "Cloud Run service URL"
  value       = try(google_cloud_run_service.fastapi_demo_service.status[0].url, null)
}

output "deployment_contract" {
  value = {
    meta = {
      contract_version = "1.0"
      cloud            = "google"
      runtime          = "cloud_run"
      application_type = "backend"
      environment      = var.environment
      region           = var.region
      deployment_type  = "serverless"
    }

    compute = {
      cluster_name  = null
      service_name  = google_cloud_run_service.fastapi_demo_service.name
      service_names = { for s, img in local.service_images : s => img }
      task_family   = null
      workload_name = null
    }

    network = {
      vpc_id            = google_compute_network.fastapi_demo_vpc.self_link
      subnet_ids        = [google_compute_subnetwork.app_subnet.self_link]
      security_group_ids = [google_compute_firewall.fastapi_demo_lb_firewall.name, google_compute_firewall.fastapi_demo_backend_firewall.name]
      ingress_id        = null
    }

    routing = {
      public_endpoint      = google_compute_global_address.fastapi_demo_lb_ip.address
      internal_endpoint    = null
      custom_domain        = null
      certificate_required = false
      certificate_mode     = null
    }

    data = {
      database_endpoint    = null
      cache_endpoint       = null
      object_store_name    = null
    }

    security = {
      certificate_ref = null
      secret_refs     = null
      role_arns       = { run_service_account = google_service_account.fastapi_demo_run_sa.email }
    }

    health = {
      frontend_path   = null
      backend_path    = "/health"
      readiness_path  = null
      liveness_path   = "/health"
    }
  }
}
