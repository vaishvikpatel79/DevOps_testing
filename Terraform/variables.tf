variable "project_name" {
  description = "Project name used in resource naming."
  type        = string
  default     = "fastapi-demo"
}

variable "environment" {
  description = "Deployment environment (e.g. dev, prod)."
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region for resource deployment."
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

variable "managed_by" {
  description = "Tag value for ManagedBy on resources."
  type        = string
  default     = "Terraform"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet1_cidr" {
  description = "CIDR block for public subnet 1."
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet2_cidr" {
  description = "CIDR block for public subnet 2."
  type        = string
  default     = "10.0.2.0/24"
}

variable "az1" {
  description = "Availability zone for subnet 1."
  type        = string
  default     = "us-east-1a"
}

variable "az2" {
  description = "Availability zone for subnet 2."
  type        = string
  default     = "us-east-1b"
}

variable "alb_listener_port" {
  description = "Port for the ALB listener."
  type        = number
  default     = 80
}

variable "desired_task_count" {
  description = "Desired number of ECS tasks for the service."
  type        = number
  default     = 1
}

variable "container_cpu_units" {
  description = "CPU units for the container/task (Fargate)."
  type        = number
  default     = 256
}

variable "container_memory_mb" {
  description = "Memory (MB) for the container/task (Fargate)."
  type        = number
  default     = 512
}

variable "container_port" {
  description = "Container port the application listens on."
  type        = number
  default     = 8000
}

variable "health_check_path" {
  description = "HTTP health check path for the target group."
  type        = string
  default     = "/health"
}

variable "health_check_interval_seconds" {
  description = "Health check interval in seconds."
  type        = number
  default     = 30
}
