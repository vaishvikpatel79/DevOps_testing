variable "project_name" {
  description = "Project name used in resource naming"
  type        = string
  default     = "fastapi-demo"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region for deployment"
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

variable "dns_hostnames_enabled" {
  description = "Enable DNS hostnames on the VPC"
  type        = bool
  default     = true
}

variable "dns_resolution_enabled" {
  description = "Enable DNS resolution on the VPC"
  type        = bool
  default     = true
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

variable "az1" {
  description = "Availability zone for subnet 1"
  type        = string
  default     = "us-east-1a"
}

variable "az2" {
  description = "Availability zone for subnet 2"
  type        = string
  default     = "us-east-1b"
}

variable "assign_public_ip" {
  description = "Whether to auto-assign public IPs on public subnets"
  type        = bool
  default     = true
}

variable "container_port" {
  description = "Container port the application listens on"
  type        = number
  default     = 8000
}

variable "cpu" {
  description = "CPU units for the task/container"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Memory (MB) for the task/container"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Desired number of ECS tasks for the service"
  type        = number
  default     = 1
}

variable "health_check_path" {
  description = "Health check path for the target group"
  type        = string
  default     = "/health"
}

variable "health_check_interval_seconds" {
  description = "Interval seconds for health checks"
  type        = number
  default     = 30
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
