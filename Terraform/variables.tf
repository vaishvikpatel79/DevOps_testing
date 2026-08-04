variable "project_name" {
  description = "Project name used in resource naming"
  type        = string
  default     = "fastapi-demo"
}

variable "environment" {
  description = "Deployment environment (dev, prod, etc.)"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
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
}

variable "container_port" {
  description = "Container port the application listens on"
  type        = number
  default     = 8000
}

variable "cpu_units" {
  description = "Container CPU units"
  type        = number
  default     = 256
}

variable "memory_mb" {
  description = "Container memory in MB"
  type        = number
  default     = 512
}

variable "fargate_cpu" {
  description = "Fargate task CPU (string as required by task_definition)"
  type        = string
  default     = "256"
}

variable "fargate_memory" {
  description = "Fargate task memory (string as required by task_definition)"
  type        = string
  default     = "512"
}

variable "desired_task_count" {
  description = "Desired number of task instances for the ECS service"
  type        = number
  default     = 1
}

variable "alb_port" {
  description = "Port for the Application Load Balancer listener"
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "Health check path for the target group"
  type        = string
  default     = "/health"
}

variable "managed_by" {
  description = "Tag value for ManagedBy"
  type        = string
  default     = "terraform"
}
