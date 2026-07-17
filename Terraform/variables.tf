variable "project_name" {
  description = "Project name used in resource naming."
  type        = string
  default     = "fastapi-demo"
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region to deploy resources into."
  type        = string
  default     = "us-east-1"
}

variable "managed_by" {
  description = "Value used in resource tags to indicate the manager/origin."
  type        = string
  default     = "terraform"
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

variable "enable_dns_support" {
  description = "Enable DNS resolution in the VPC."
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
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

variable "public_subnet_1_map_public_ip_on_launch" {
  description = "Whether to auto-assign public IPv4 addresses for instances launched into this subnet."
  type        = bool
  default     = true
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

variable "public_subnet_2_map_public_ip_on_launch" {
  description = "Whether to auto-assign public IPv4 addresses for instances launched into this subnet."
  type        = bool
  default     = true
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

variable "container_memory" {
  description = "Memory (MB) for the container."
  type        = number
  default     = 512
}

variable "container_port" {
  description = "Port the container listens on."
  type        = number
  default     = 8000
}

variable "health_check_path" {
  description = "Health check path for the ALB target group."
  type        = string
  default     = "/health"
}

variable "health_check_protocol" {
  description = "Health check protocol for the ALB target group."
  type        = string
  default     = "HTTP"
}

variable "health_check_port" {
  description = "Health check port for the ALB target group."
  type        = string
  default     = "traffic-port"
}

variable "health_check_interval" {
  description = "Interval seconds for the target group health check."
  type        = number
  default     = 30
}

variable "healthy_threshold" {
  description = "Healthy threshold count for the target group."
  type        = number
  default     = 2
}

variable "unhealthy_threshold" {
  description = "Unhealthy threshold count for the target group."
  type        = number
  default     = 3
}

variable "listener_port" {
  description = "Port for the ALB HTTP listener."
  type        = number
  default     = 80
}
