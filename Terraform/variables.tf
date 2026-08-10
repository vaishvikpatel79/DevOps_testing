variable "project_name" {
  description = "Project name used in resource naming"
  type        = string
  default     = "fastapi-demo"
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "us-east-1"
}

variable "managed_by" {
  description = "Tag value for ManagedBy on resources"
  type        = string
  default     = "Terraform"
}

variable "service_tags" {
  description = "Map of service name to image tag. Terraform constructs full ECR URIs from this map."
  type        = map(string)
  default     = {}
}

variable "service_repositories" {
  description = "Map of logical service name to container repository name."
  type        = map(string)
  default     = {
    "fastapi-demo-service" = "fastapi-demo-service"
  }
}

variable "account_id" {
  description = "AWS account ID used to construct ECR image URIs."
  type        = string
  default     = "220897588425"
}

variable "desired_task_count" {
  description = "Desired number of ECS tasks for the service"
  type        = number
  default     = 1
}

variable "container_cpu" {
  description = "CPU units for the container"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Memory (MB) for the container"
  type        = number
  default     = 512
}

variable "container_port" {
  description = "Container port the application listens on"
  type        = number
  default     = 8000
}

variable "health_check_path" {
  description = "Health check path for the service"
  type        = string
  default     = "/health"
}

variable "health_check_interval_seconds" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
}

variable "healthy_threshold_count" {
  description = "Healthy threshold count for target group health checks"
  type        = number
  default     = 2
}

variable "unhealthy_threshold_count" {
  description = "Unhealthy threshold count for target group health checks"
  type        = number
  default     = 3
}

variable "alb_listener_port" {
  description = "Port for ALB listener"
  type        = number
  default     = 80
}
