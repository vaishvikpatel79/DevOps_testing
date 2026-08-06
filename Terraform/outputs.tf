output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.application_lb.dns_name
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.fastapi-demo-cluster.name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.fastapi-demo-service.name
}

output "ecs_task_definition_arn" {
  description = "ECS task definition ARN"
  value       = aws_ecs_task_definition.fastapi-demo-task.arn
}

output "ecr_image_uri_fastapi_demo_service" {
  description = "Constructed ECR image URI for the fastapi-demo-service"
  value       = local.service_images["fastapi-demo-service"]
}

output "cloudwatch_log_group_name" {
  description = "CloudWatch log group for ECS tasks"
  value       = aws_cloudwatch_log_group.ecs-log-group.name
}

output "deployment_contract" {
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
      cluster_name  = aws_ecs_cluster.fastapi-demo-cluster.name
      service_name  = aws_ecs_service.fastapi-demo-service.name
      service_names = { "fastapi-demo-service" = aws_ecs_service.fastapi-demo-service.name }
      task_family   = aws_ecs_task_definition.fastapi-demo-task.family
      workload_name = null
    }

    network = {
      vpc_id             = aws_vpc.fastapi-demo-vpc.id
      subnet_ids         = [aws_subnet.public-subnet-1.id, aws_subnet.public-subnet-2.id]
      security_group_ids = [aws_security_group.alb-sg.id, aws_security_group.ecs-service-sg.id]
      ingress_id         = aws_lb.application_lb.id
    }

    routing = {
      public_endpoint        = aws_lb.application_lb.dns_name
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
      role_arns       = { "ecs_task_execution_role" = aws_iam_role.ecs-task-execution-role.arn }
    }

    health = {
      frontend_path   = null
      backend_path    = "/health"
      readiness_path  = null
      liveness_path   = null
    }
  }
}
