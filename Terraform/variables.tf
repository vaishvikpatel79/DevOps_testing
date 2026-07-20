variable "project_name" {
  description = "Project name used in resource names and tags."
  type        = string
  default     = "fastapi-demo"
}

variable "environment" {
  description = "Deployment environment (used in names and tags)."
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region to deploy resources into."
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
  description = "CIDR block for the primary VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "dns_resolution_enabled" {
  description = "Enable DNS resolution in the VPC."
  type        = bool
  default     = true
}

variable "dns_hostnames_enabled" {
  description = "Enable DNS hostnames in the VPC."
  type        = bool
  default     = true
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for public subnet 1."
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_1_az" {
  description = "Availability zone for public subnet 1."
  type        = string
  default     = "us-east-1a"
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for public subnet 2."
  type        = string
  default     = "10.0.2.0/24"
}

variable "public_subnet_2_az" {
  description = "Availability zone for public subnet 2."
  type        = string
  default     = "us-east-1b"
}

variable "map_public_ip_on_launch" {
  description = "Whether to auto-assign public IPs for instances in public subnets."
  type        = bool
  default     = true
}

variable "container_port" {
  description = "Container port the service listens on."
  type        = number
  default     = 8000
}

variable "cpu_units" {
  description = "CPU units for the container."
  type        = number
  default     = 256
}

variable "memory_mb" {
  description = "Memory (MB) for the container."
  type        = number
  default     = 512
}

variable "desired_task_count" {
  description = "Desired number of ECS tasks."
  type        = number
  default     = 1
}

variable "health_check_path" {
  description = "Health check HTTP path for the target group."
  type        = string
  default     = "/health"
}

variable "health_check_protocol" {
  description = "Health check protocol for the target group."
  type        = string
  default     = "HTTP"
}

variable "health_check_port" {
  description = "Health check port for the target group. Use 'traffic-port' to use target port."
  type        = string
  default     = "traffic-port"
}

variable "healthy_threshold_count" {
  description = "Number of successful checks before considering target healthy."
  type        = number
  default     = 2
}

variable "unhealthy_threshold_count" {
  description = "Number of failed checks before considering target unhealthy."
  type        = number
  default     = 3
}

variable "health_check_interval_seconds" {
  description = "Interval between health checks in seconds."
  type        = number
  default     = 30
}
