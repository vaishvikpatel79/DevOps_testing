variable "project_name" {
  description = "Project name"
  type        = string
  default     = "fastapi-demo"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region for resource deployment"
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
  default     = {
    "fastapi-demo-service" = "fastapi-demo-service"
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet1_cidr" {
  description = "CIDR block for public subnet 1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet2_cidr" {
  description = "CIDR block for public subnet 2"
  type        = string
  default     = "10.0.2.0/24"
}

variable "subnet1_az" {
  description = "Availability zone for public subnet 1"
  type        = string
  default     = "us-east-1a"
}

variable "subnet2_az" {
  description = "Availability zone for public subnet 2"
  type        = string
  default     = "us-east-1b"
}

variable "subnet1_map_public_ip" {
  description = "Whether to auto-assign public IP for subnet 1"
  type        = bool
  default     = true
}

variable "subnet2_map_public_ip" {
  description = "Whether to auto-assign public IP for subnet 2"
  type        = bool
  default     = true
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

variable "read_only_root_filesystem" {
  description = "Whether the container root filesystem is read-only"
  type        = bool
  default     = false
}

variable "desired_count" {
  description = "Desired number of ECS tasks for the service"
  type        = number
  default     = 1
}

variable "health_check_path" {
  description = "Health check path for the target group"
  type        = string
  default     = "/health"
}

variable "health_check_protocol" {
  description = "Health check protocol for the target group"
  type        = string
  default     = "HTTP"
}

variable "health_check_interval_seconds" {
  description = "Health check interval in seconds for the target group"
  type        = number
  default     = 30
}

variable "healthy_threshold_count" {
  description = "Number of successful checks before considering target healthy"
  type        = number
  default     = 2
}

variable "unhealthy_threshold_count" {
  description = "Number of failed checks before considering target unhealthy"
  type        = number
  default     = 3
}
