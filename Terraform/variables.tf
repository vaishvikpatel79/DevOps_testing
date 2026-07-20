variable "project_name" {
  description = "Project name, used as prefix for resource names"
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

variable "public_subnet1_cidr" {
  description = "CIDR block for public subnet 1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet2_cidr" {
  description = "CIDR block for public subnet 2"
  type        = string
  default     = "10.0.2.0/24"
}

variable "public_subnet_az1" {
  description = "Availability zone for public subnet 1"
  type        = string
  default     = "us-east-1a"
}

variable "public_subnet_az2" {
  description = "Availability zone for public subnet 2"
  type        = string
  default     = "us-east-1b"
}

variable "container_port" {
  description = "Container port the application listens on"
  type        = number
  default     = 8000
}

variable "container_cpu" {
  description = "CPU units to assign to the container"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Memory (MB) to assign to the container"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Desired number of ECS tasks for the service"
  type        = number
  default     = 1
}

variable "health_check_path" {
  description = "Health check HTTP path for target group"
  type        = string
  default     = "/health"
}

variable "health_check_interval_seconds" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
}

variable "healthy_threshold_count" {
  description = "Healthy threshold count for health checks"
  type        = number
  default     = 2
}

variable "unhealthy_threshold_count" {
  description = "Unhealthy threshold count for health checks"
  type        = number
  default     = 3
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

variable "managed_by" {
  description = "Value used in ManagedBy tag"
  type        = string
  default     = "Terraform"
}
