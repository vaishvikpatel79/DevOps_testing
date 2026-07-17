output "alb_dns" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.alb.dns_name
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.ecr_repo.repository_url
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.ecs_cluster.name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.ecs_service.name
}

output "ecs_task_definition_arn" {
  description = "ECS task definition ARN"
  value       = aws_ecs_task_definition.task_definition.arn
}

output "service_image_uri" {
  description = "Full ECR image URI for the backend service (constructed from var.service_tags)"
  value       = local.service_images[var.backend_service_name]
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
}

output "security_group_ids" {
  description = "Security groups for ALB and ECS tasks"
  value = {
    alb_sg = aws_security_group.alb_sg.id
    ecs_sg = aws_security_group.ecs_service_sg.id
  }
}

output "deployment_contract" {
  description = "Canonical deployment contract for the Deployment Agent"
  value = {
    meta = {
      contract_version = "1.0"
      cloud            = "aws"
      runtime          = "docker"
      application_type = "backend"
      environment      = var.environment
      region           = var.region
      deployment_type  = "ecs_fargate"
    }

    compute = {
      cluster_name  = aws_ecs_cluster.ecs_cluster.name
      service_name  = aws_ecs_service.ecs_service.name
      service_names = { (var.backend_service_name) = aws_ecs_service.ecs_service.name }
      task_family   = aws_ecs_task_definition.task_definition.family
      workload_name = aws_ecs_service.ecs_service.name
    }

    network = {
      vpc_id             = aws_vpc.vpc.id
      subnet_ids         = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
      security_group_ids = [aws_security_group.alb_sg.id, aws_security_group.ecs_service_sg.id]
      ingress_id         = aws_lb.alb.arn
    }

    routing = {
      public_endpoint      = aws_lb.alb.dns_name
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
      role_arns = {
        ecs_task_execution_role = aws_iam_role.ecs_task_execution_role.arn
      }
    }

    health = {
      frontend_path  = null
      backend_path   = var.health_check_path
      readiness_path = var.health_check_path
      liveness_path  = var.health_check_path
    }
  }
}
