output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.fastapi-demo-dev_alb.dns_name
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.fastapi-demo-dev_cluster.name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.fastapi-demo-dev_service.name
}

output "ecs_task_definition_arn" {
  description = "ECS task definition ARN"
  value       = aws_ecs_task_definition.fastapi-demo-dev_task_def.arn
}

output "ecr_image_uri" {
  description = "Constructed ECR image URI for the service (from var.service_tags)"
  value       = local.service_images["fastapi-demo-service"]
}

output "deployment_contract" {
  description = "Canonical deployment contract for the deployment agent"
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
      cluster_name  = aws_ecs_cluster.fastapi-demo-dev_cluster.name
      service_name  = aws_ecs_service.fastapi-demo-dev_service.name
      service_names = { "fastapi-demo-service" = aws_ecs_service.fastapi-demo-dev_service.name }
      task_family   = aws_ecs_task_definition.fastapi-demo-dev_task_def.family
      workload_name = null
    }

    network = {
      vpc_id             = aws_vpc.fastapi-demo-dev_vpc.id
      subnet_ids         = [aws_subnet.fastapi-demo-dev_public_subnet_1.id, aws_subnet.fastapi-demo-dev_public_subnet_2.id]
      security_group_ids = [aws_security_group.fastapi-demo-dev_alb_sg.id, aws_security_group.fastapi-demo-dev_ecs_sg.id]
      ingress_id         = aws_internet_gateway.fastapi-demo-dev_igw.id
    }

    routing = {
      public_endpoint       = "http://${aws_lb.fastapi-demo-dev_alb.dns_name}"
      internal_endpoint     = null
      custom_domain         = null
      certificate_required  = false
      certificate_mode      = null
    }

    data = {
      database_endpoint    = null
      cache_endpoint       = null
      object_store_name    = null
    }

    security = {
      certificate_ref = null
      secret_refs     = null
      role_arns       = { "task_execution_role" = aws_iam_role.fastapi-demo-dev_task_exec_role.arn }
    }

    health = {
      frontend_path  = null
      backend_path   = var.health_check_path
      readiness_path = null
      liveness_path  = null
    }
  }
}
