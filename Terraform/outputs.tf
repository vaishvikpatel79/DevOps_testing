output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.alb.dns_name
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.fastapi_demo_cluster.name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.fastapi_demo_service.name
}

output "ecs_task_definition_arn" {
  description = "ARN of the ECS task definition"
  value       = aws_ecs_task_definition.fastapi_demo_task_def.arn
}

output "ecr_image_uri" {
  description = "ECR image URI constructed for the service"
  value       = local.service_images["fastapi-demo-service"]
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
      cluster_name  = aws_ecs_cluster.fastapi_demo_cluster.name
      service_name  = aws_ecs_service.fastapi_demo_service.name
      service_names = { for s in keys(local.service_images) : s => aws_ecs_service.fastapi_demo_service.name }
      task_family   = aws_ecs_task_definition.fastapi_demo_task_def.family
      workload_name = null
    }

    network = {
      vpc_id             = aws_vpc.fastapi_demo_vpc.id
      subnet_ids         = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
      security_group_ids = [aws_security_group.ecs_service_sg.id, aws_security_group.alb_sg.id]
      ingress_id         = null
    }

    routing = {
      public_endpoint        = aws_lb.alb.dns_name
      internal_endpoint      = null
      custom_domain          = null
      certificate_required   = false
      certificate_mode       = null
    }

    data = {
      database_endpoint   = null
      cache_endpoint      = null
      object_store_name   = null
    }

    security = {
      certificate_ref = null
      secret_refs     = null
      role_arns       = { ecs_task_execution = aws_iam_role.ecs_task_execution_role.arn }
    }

    health = {
      frontend_path  = null
      backend_path   = "/health"
      readiness_path = "/health"
      liveness_path  = "/health"
    }
  }
}
