variable "service_tags" {
  description = "Map of service name to image tag. Terraform constructs full ECR URIs from this map."
  type        = map(string)
  default     = {}
}

variable "account_id" {
  description = "AWS account ID used to construct ECR image URIs."
  type        = string
  default     = "220897588425"
}

variable "project_name" {
  description = "Project name used in resource naming."
  type        = string
  default     = "fastapi-demo"
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "desired_task_count" {
  description = "Desired number of ECS tasks for the service."
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
  description = "HTTP health check path for target group"
  type        = string
  default     = "/health"
}

variable "health_check_port" {
  description = "Port used by health check (use \"traffic-port\" to use target port)"
  type        = string
  default     = "traffic-port"
}

variable "healthy_threshold" {
  description = "Healthy threshold count for target group health check"
  type        = number
  default     = 2
}

variable "unhealthy_threshold" {
  description = "Unhealthy threshold count for target group health check"
  type        = number
  default     = 3
}

variable "health_check_interval" {
  description = "Health check interval in seconds for the target group"
  type        = number
  default     = 30
}
