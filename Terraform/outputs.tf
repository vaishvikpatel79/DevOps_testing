output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.alb.dns_name
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
  value       = aws_ecs_task_definition.task_def.arn
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.ecr_repository.repository_url
}

output "ecr_image_uri" {
  description = "Full ECR image URI for the service (constructed from service_tags)."
  value       = local.service_images["fastapi-demo-service"]
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.fastapi_demo_vpc.id
}

output "subnet_ids" {
  description = "Public subnet IDs"
  value       = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
}

output "alb_arn" {
  description = "ALB ARN"
  value       = aws_lb.alb.arn
}

output "target_group_arn" {
  description = "Target group ARN"
  value       = aws_lb_target_group.fastapi_demo_tg.arn
}

output "deployment_contract" {
  description = "Canonical deployment contract for the deployment agent"
  value = {
    meta = {
      contract_version = "1.0"
      cloud            = "aws"
      runtime          = "ecs_fargate"
      application_type = "backend"
      environment      = var.environment
      region           = var.region
      deployment_type  = "fargate"
    }

    compute = {
      cluster_name  = aws_ecs_cluster.ecs_cluster.name
      service_name  = aws_ecs_service.fastapi_demo_service.name
      service_names = { "fastapi-demo-service" = aws_ecs_service.fastapi_demo_service.name }
      task_family   = aws_ecs_task_definition.task_def.family
      workload_name = aws_ecs_service.fastapi_demo_service.name
    }

    network = {
      vpc_id             = aws_vpc.fastapi_demo_vpc.id
      subnet_ids         = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
      security_group_ids = [aws_security_group.ecs_service_sg.id, aws_security_group.alb_sg.id]
      ingress_id         = null
    }

    routing = {
      public_endpoint      = "http://${aws_lb.alb.dns_name}"
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
      role_arns       = { "ecs_task_execution_role" = aws_iam_role.ecs_task_execution_role.arn }
    }

    health = {
      frontend_path  = null
      backend_path   = var.health_check_path
      readiness_path = null
      liveness_path  = null
    }
  }
}
