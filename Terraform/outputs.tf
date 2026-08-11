output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.fastapi-demo-dev_alb.dns_name
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.fastapi-demo-dev_cluster.name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.fastapi-demo-dev_service.name
}

output "ecs_task_definition_arn" {
  description = "ARN of the ECS task definition"
  value       = aws_ecs_task_definition.fastapi-demo-dev_task_def.arn
}

output "ecr_image_uri" {
  description = "Constructed ECR image URI for the fastapi-demo-service from service_tags/service_repositories"
  value       = local.service_images["fastapi-demo-service"]
}

output "deployment_contract" {
  value = {
    meta = {
      contract_version = "1.0"
      cloud = "aws"
      runtime = "ecs"
      application_type = "backend"
      environment = var.environment
      region = var.region
      deployment_type = "fargate"
    }

    compute = {
      cluster_name = aws_ecs_cluster.fastapi-demo-dev_cluster.name
      service_name = aws_ecs_service.fastapi-demo-dev_service.name
      service_names = { "fastapi-demo-service" = aws_ecs_service.fastapi-demo_service.name }
      task_family = aws_ecs_task_definition.fastapi-demo-dev_task_def.family
      workload_name = null
    }

    network = {
      vpc_id = aws_vpc.fastapi-demo-dev_vpc.id
      subnet_ids = [aws_subnet.fastapi-demo-dev_public_subnet_1.id, aws_subnet.fastapi-demo-dev_public_subnet_2.id]
      security_group_ids = [aws_security_group.fastapi-demo-dev_alb_sg.id, aws_security_group.fastapi-demo-dev_ecs_service_sg.id]
      ingress_id = aws_lb.fastapi-demo-dev_alb.arn
    }

    routing = {
      public_endpoint = aws_lb.fastapi-demo-dev_alb.dns_name
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
      role_arns = { "ecs_task_execution_role" = aws_iam_role.fastapi-demo-dev_ecs_task_execution_role.arn }
    }

    health = {
      frontend_path = null
      backend_path = var.health_check_path
      readiness_path = null
      liveness_path = null
    }
  }
}
