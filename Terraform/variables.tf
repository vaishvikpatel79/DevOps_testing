variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "fastapi-demo"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region to deploy resources in"
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
  default     = {}
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of CIDRs for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnet_azs" {
  description = "List of availability zones for public subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "desired_task_count" {
  description = "Number of desired ECS tasks for the service"
  type        = number
  default     = 1
}

variable "container_cpu" {
  description = "CPU units for the Fargate task (string expected by task definition)"
  type        = string
  default     = "256"
}

variable "container_memory" {
  description = "Memory (MiB) for the Fargate task (string expected by task definition)"
  type        = string
  default     = "512"
}

variable "container_port" {
  description = "Container port that the application listens on"
  type        = number
  default     = 8000
}

variable "read_only_root_filesystem" {
  description = "Whether the container root filesystem is read-only"
  type        = bool
  default     = false
}

variable "health_check_path" {
  description = "Health check path for the target group"
  type        = string
  default     = "/health"
}

variable "health_check_interval_seconds" {
  description = "Interval in seconds between health checks"
  type        = number
  default     = 30
}

variable "health_check_healthy_threshold" {
  description = "Healthy threshold for the target group health check"
  type        = number
  default     = 2
}

variable "health_check_unhealthy_threshold" {
  description = "Unhealthy threshold for the target group health check"
  type        = number
  default     = 3
}

variable "managed_by" {
  description = "Tag value for ManagedBy"
  type        = string
  default     = "terraform"
}
