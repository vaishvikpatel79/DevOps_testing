variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "fastapi-demo"
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)"
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

variable "account_id" {
  description = "AWS account ID used to construct ECR image URIs."
  type        = string
  default     = "220897588425"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_dns_support" {
  description = "Enable DNS support on the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames on the VPC"
  type        = bool
  default     = true
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for public subnet 1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_1_az" {
  description = "Availability zone for public subnet 1"
  type        = string
  default     = "us-east-1a"
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for public subnet 2"
  type        = string
  default     = "10.0.2.0/24"
}

variable "public_subnet_2_az" {
  description = "Availability zone for public subnet 2"
  type        = string
  default     = "us-east-1b"
}

variable "alb_listener_port" {
  description = "Port for the ALB listener"
  type        = number
  default     = 80
}

variable "backend_port" {
  description = "Container port the backend listens on"
  type        = number
  default     = 8000
}

variable "desired_task_count" {
  description = "Number of desired ECS tasks for the service"
  type        = number
  default     = 1
}

variable "cpu_units" {
  description = "CPU units for the task definition"
  type        = number
  default     = 256
}

variable "memory_mb" {
  description = "Memory (MB) for the task definition"
  type        = number
  default     = 512
}

variable "health_check_path" {
  description = "Health check path for the target group"
  type        = string
  default     = "/health"
}

variable "health_check_interval_seconds" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
}

variable "healthy_threshold_count" {
  description = "Number of successful checks before target is considered healthy"
  type        = number
  default     = 2
}

variable "unhealthy_threshold_count" {
  description = "Number of failed checks before target is considered unhealthy"
  type        = number
  default     = 3
}

variable "health_check_protocol" {
  description = "Protocol used for health checks"
  type        = string
  default     = "HTTP"
}

variable "health_check_port" {
  description = "Port used for health checks (can be 'traffic-port')"
  type        = string
  default     = "traffic-port"
}
