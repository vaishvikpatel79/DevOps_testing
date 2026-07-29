variable "project_name" {
  description = "The project name used as a prefix for resource names."
  type        = string
  default     = "fastapi-demo"
}

variable "environment" {
  description = "Deployment environment (used in resource names and tags)."
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region to deploy resources into."
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
  default = {
    "fastapi-demo-service" = "fastapi-demo-service"
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for the first public subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for the second public subnet."
  type        = string
  default     = "10.0.2.0/24"
}

variable "availability_zone_1" {
  description = "Availability zone for the first public subnet."
  type        = string
  default     = "us-east-1a"
}

variable "availability_zone_2" {
  description = "Availability zone for the second public subnet."
  type        = string
  default     = "us-east-1b"
}

variable "container_port" {
  description = "Container port the application listens on."
  type        = number
  default     = 8000
}

variable "cpu_units" {
  description = "CPU units for the container/task."
  type        = number
  default     = 256
}

variable "memory_mb" {
  description = "Memory (MB) for the container/task."
  type        = number
  default     = 512
}

variable "desired_task_count" {
  description = "Desired number of ECS tasks for the service."
  type        = number
  default     = 1
}

variable "health_check_path" {
  description = "Health check path for the ALB target group."
  type        = string
  default     = "/health"
}

variable "health_check_port" {
  description = "Health check port for the ALB target group."
  type        = string
  default     = "traffic-port"
}

variable "health_check_protocol" {
  description = "Health check protocol for the ALB target group."
  type        = string
  default     = "HTTP"
}

variable "healthy_threshold_count" {
  description = "Healthy threshold count for target group health check."
  type        = number
  default     = 2
}

variable "unhealthy_threshold_count" {
  description = "Unhealthy threshold count for target group health check."
  type        = number
  default     = 3
}

variable "health_check_interval_seconds" {
  description = "Interval seconds for target group health checks."
  type        = number
  default     = 30
}
