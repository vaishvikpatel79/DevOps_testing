variable "project_name" {
  description = "Project name used in resource naming"
  type        = string
  default     = "fastapi-demo"
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
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

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "CIDR for public subnet 1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "CIDR for public subnet 2"
  type        = string
  default     = "10.0.2.0/24"
}

variable "public_subnet_1_az" {
  description = "Availability zone for public subnet 1"
  type        = string
  default     = "us-east-1a"
}

variable "public_subnet_2_az" {
  description = "Availability zone for public subnet 2"
  type        = string
  default     = "us-east-1b"
}

variable "backend_service_name" {
  description = "Container service name as provided by the user"
  type        = string
  default     = "fastapi-demo-service"
}

variable "desired_task_count" {
  description = "Number of desired ECS tasks for the service"
  type        = number
  default     = 1
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 8000
}

variable "cpu_units" {
  description = "CPU units reserved for the task/container"
  type        = number
  default     = 256
}

variable "memory_mb" {
  description = "Memory (MB) reserved for the task/container"
  type        = number
  default     = 512
}

variable "health_check_path" {
  description = "Health check HTTP path for the target group"
  type        = string
  default     = "/health"
}

variable "health_check_port" {
  description = "Health check port for the target group (use 'traffic-port' for ALB)"
  type        = string
  default     = "traffic-port"
}

variable "healthy_threshold_count" {
  description = "Healthy threshold count for the target group health check"
  type        = number
  default     = 2
}

variable "unhealthy_threshold_count" {
  description = "Unhealthy threshold count for the target group health check"
  type        = number
  default     = 3
}

variable "health_check_interval_seconds" {
  description = "Health check interval seconds for the target group"
  type        = number
  default     = 30
}

variable "managed_by" {
  description = "Value used for ManagedBy tag on resources"
  type        = string
  default     = "terraform"
}
