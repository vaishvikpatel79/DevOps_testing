variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "fastapi-demo"
}

variable "environment" {
  description = "Deployment environment (dev/stage/prod)"
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
  default     = { "fastapi-demo-service" = "fastapi-demo-service" }
}

variable "account_id" {
  description = "AWS account ID used to construct ECR image URIs."
  type        = string
  default     = "220897588425"
}

variable "vpc_cidr" {
  description = "CIDR block for the primary VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for public subnet 1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for public subnet 2"
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

variable "public_subnet_auto_assign" {
  description = "Whether public subnets should auto assign public IPs"
  type        = bool
  default     = true
}

variable "desired_task_count" {
  description = "Desired number of ECS tasks for the service"
  type        = number
  default     = 1
}

variable "cpu_units" {
  description = "CPU units for the Fargate task"
  type        = number
  default     = 256
}

variable "memory_mb" {
  description = "Memory (MB) for the Fargate task"
  type        = number
  default     = 512
}

variable "container_port" {
  description = "Container port the application listens on"
  type        = number
  default     = 8000
}

variable "read_only_root_filesystem" {
  description = "Whether the container root filesystem is read only"
  type        = bool
  default     = false
}

variable "health_check_path" {
  description = "Health check path for the ALB target group"
  type        = string
  default     = "/health"
}

variable "health_check_protocol" {
  description = "Health check protocol for the ALB target group"
  type        = string
  default     = "HTTP"
}
