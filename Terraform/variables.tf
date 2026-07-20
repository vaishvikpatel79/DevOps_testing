variable "project_name" {
  description = "Project name used in resource naming"
  type        = string
  default     = "fastapi-demo"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "account_id" {
  description = "AWS account ID used to construct ECR image URIs."
  type        = string
  default     = "220897588425"
}

variable "service_tags" {
  description = "Map of service name to image tag. Terraform constructs full ECR URIs from this map."
  type        = map(string)
  default     = {}
}

variable "service_repositories" {
  description = "Map of logical service name to container repository name."
  type        = map(string)
  default     = {}
}

variable "desired_task_count" {
  description = "Desired number of tasks for the ECS service"
  type        = number
  default     = 1
}

variable "container_port" {
  description = "Container port the application listens on"
  type        = number
  default     = 8000
}

variable "cpu_units" {
  description = "CPU units for the task/container"
  type        = number
  default     = 256
}

variable "memory_mb" {
  description = "Memory (MB) for the task/container"
  type        = number
  default     = 512
}

variable "managed_by" {
  description = "Tag value for ManagedBy tag"
  type        = string
  default     = "terraform"
}
