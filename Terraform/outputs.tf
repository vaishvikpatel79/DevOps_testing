output "alb_dns_name" {
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
  value       = aws_ecs_task_definition.fastapi_demo_task.arn
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.ecr_repo.repository_url
}

output "deployment_contract" {
  description = "Canonical deployment contract for the Deployment Agent"
  value = {
    meta = {
      contract_version = "1.0"
      cloud            = "aws"
      runtime          = "ecs_fargate"
      application_type = "backend-only"
      environment      = var.environment
      region           = var.region
      deployment_type  = "container"
    }

    compute = {
      cluster_name = aws_ecs_cluster.ecs_cluster.name
      service_name = aws_ecs_service.fastapi_demo_service.name
      service_names = {
        "fastapi-demo-service" = aws_ecs_service.fastapi_demo_service.name
      }
      task_family   = aws_ecs_task_definition.fastapi_demo_task.family
      workload_name = aws_ecs_service.fastapi_demo_service.name
    }

    network = {
      vpc_id             = aws_vpc.fastapi_demo_vpc.id
      subnet_ids         = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
      security_group_ids = [aws_security_group.alb_sg.id, aws_security_group.ecs_service_sg.id]
      ingress_id         = null
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
      role_arns = {
        ecs_task_execution_role = aws_iam_role.ecs_task_execution_role.arn
      }
    }

    health = {
      frontend_path  = null
      backend_path   = var.health_check_path
      readiness_path = null
      liveness_path  = null
    }
  }
}
