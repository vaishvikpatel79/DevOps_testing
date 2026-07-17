output "alb_dns" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.application_load_balancer.dns_name
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.ecs_cluster.name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.fastapi_demo_service.name
}

output "ecs_task_definition_arn" {
  description = "ECS task definition ARN"
  value       = aws_ecs_task_definition.fastapi_task_definition.arn
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.ecr_repository.repository_url
}

output "ecr_image_uri" {
  description = "Full ECR image URI constructed from service_tags for the primary service"
  value       = local.service_images[var.service_name]
}

output "deployment_contract" {
  description = "Canonical deployment contract for the Deployment Agent"
  value = {
    meta = {
      contract_version = "1.0"
      cloud            = "aws"
      runtime          = "ecs"
      application_type = "backend"
      environment      = var.environment
      region           = var.region
      deployment_type  = "fargate"
    }

    compute = {
      cluster_name  = aws_ecs_cluster.ecs_cluster.name
      service_name  = aws_ecs_service.fastapi_demo_service.name
      service_names = { (var.service_name) = aws_ecs_service.fastapi_demo_service.name }
      task_family   = aws_ecs_task_definition.fastapi_task_definition.family
      workload_name = null
    }

    network = {
      vpc_id             = aws_vpc.fastapi_demo_vpc.id
      subnet_ids         = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
      security_group_ids = [aws_security_group.alb_sg.id, aws_security_group.ecs_service_sg.id]
      ingress_id         = aws_lb.application_load_balancer.arn
    }

    routing = {
      public_endpoint      = aws_lb.application_load_balancer.dns_name
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
      role_arns       = { execution_role = aws_iam_role.ecs_task_execution_role.arn }
    }

    health = {
      frontend_path  = null
      backend_path   = var.health_check_path
      readiness_path = var.health_check_path
      liveness_path  = var.health_check_path
    }
  }
}
