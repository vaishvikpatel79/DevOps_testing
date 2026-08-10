variable "project_name" {
  description = "Project name used in resource naming"
  type        = string
  default     = "fastapi-demo"
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
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

variable "account_id" {
  description = "AWS account ID used to construct ECR image URIs."
  type        = string
  default     = "220897588425"
}

variable "dns_resolution_enabled" {
  description = "Enable VPC DNS resolution"
  type        = bool
  default     = true
}

variable "dns_hostnames_enabled" {
  description = "Enable VPC DNS hostnames"
  type        = bool
  default     = true
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

variable "desired_count" {
  description = "Desired number of ECS tasks for the service"
  type        = number
  default     = 1
}
