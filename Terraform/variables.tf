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
  description = "Environment name used in resource naming."
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "managed_by" {
  description = "ManagedBy tag value for resources."
  type        = string
  default     = "terraform"
}

variable "desired_task_count" {
  description = "Desired number of ECS tasks for the service."
  type        = number
  default     = 1
}

variable "container_cpu" {
  description = "CPU units for the container."
  type        = number
  default     = 256
}

variable "container_memory_mb" {
  description = "Memory for the container in MB."
  type        = number
  default     = 512
}

variable "container_port" {
  description = "Port the container listens on."
  type        = number
  default     = 8000
}

variable "health_check_path" {
  description = "Health check path for the load balancer target group."
  type        = string
  default     = "/health"
}

variable "health_check_protocol" {
  description = "Health check protocol for the target group."
  type        = string
  default     = "HTTP"
}

variable "health_check_port" {
  description = "Health check port for the target group."
  type        = string
  default     = "traffic-port"
}

variable "health_check_interval_seconds" {
  description = "Health check interval in seconds."
  type        = number
  default     = 30
}

variable "healthy_threshold" {
  description = "Healthy threshold count for target group health checks."
  type        = number
  default     = 2
}

variable "unhealthy_threshold" {
  description = "Unhealthy threshold count for target group health checks."
  type        = number
  default     = 3
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for public subnet 1."
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for public subnet 2."
  type        = string
  default     = "10.0.2.0/24"
}

variable "public_subnet_1_az" {
  description = "Availability zone for public subnet 1."
  type        = string
  default     = "us-east-1a"
}

variable "public_subnet_2_az" {
  description = "Availability zone for public subnet 2."
  type        = string
  default     = "us-east-1b"
}
