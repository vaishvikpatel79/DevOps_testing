variable "project_name" {
  description = "Project name used in resource naming"
  type        = string
  default     = "fastapi-demo"
}

variable "environment" {
  description = "Deployment environment (used in names and tags)"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region to deploy resources into"
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

variable "vpc_cidr_block" {
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

variable "container_port" {
  description = "Container port the application listens on"
  type        = number
  default     = 8000
}

variable "cpu_units" {
  description = "CPU units for the ECS task/container"
  type        = number
  default     = 256
}

variable "memory_mb" {
  description = "Memory (MB) for the ECS task/container"
  type        = number
  default     = 512
}

variable "desired_task_count" {
  description = "Desired number of ECS tasks for the service"
  type        = number
  default     = 1
}

variable "health_check_path" {
  description = "Health check path for target group"
  type        = string
  default     = "/health"
}

variable "health_check_port" {
  description = "Health check port for target group"
  type        = string
  default     = "traffic-port"
}

variable "health_check_protocol" {
  description = "Health check protocol for target group"
  type        = string
  default     = "HTTP"
}

variable "healthy_threshold_count" {
  description = "Healthy threshold count for target group health check"
  type        = number
  default     = 2
}

variable "unhealthy_threshold_count" {
  description = "Unhealthy threshold count for target group health check"
  type        = number
  default     = 3
}

variable "health_check_interval_seconds" {
  description = "Interval seconds for target group health check"
  type        = number
  default     = 30
}

variable "managed_by" {
  description = "Tag value for ManagedBy"
  type        = string
  default     = "Terraform"
}
