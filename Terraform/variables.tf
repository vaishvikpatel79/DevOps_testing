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

variable "service_name" {
  description = "Primary service name (must match keys in service_tags)."
  type        = string
  default     = "fastapi-demo-service"
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

variable "public_subnet_1_map_public_ip" {
  description = "Whether to map public IP on launch for subnet 1."
  type        = bool
  default     = true
}

variable "public_subnet_2_map_public_ip" {
  description = "Whether to map public IP on launch for subnet 2."
  type        = bool
  default     = true
}

variable "alb_listener_port" {
  description = "Port for the ALB listener."
  type        = number
  default     = 80
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

variable "desired_count" {
  description = "Desired number of ECS tasks to run."
  type        = number
  default     = 1
}

variable "health_check_path" {
  description = "Health check path for target group."
  type        = string
  default     = "/health"
}

variable "health_check_protocol" {
  description = "Health check protocol for target group."
  type        = string
  default     = "HTTP"
}

variable "health_check_port" {
  description = "Health check port for target group (string allowed, e.g., \"traffic-port\")."
  type        = string
  default     = "traffic-port"
}

variable "health_check_interval_seconds" {
  description = "Interval seconds for target group health checks."
  type        = number
  default     = 30
}

variable "healthy_threshold_count" {
  description = "Healthy threshold count for target group health checks."
  type        = number
  default     = 2
}

variable "unhealthy_threshold_count" {
  description = "Unhealthy threshold count for target group health checks."
  type        = number
  default     = 3
}

variable "managed_by" {
  description = "ManagedBy tag value for resources."
  type        = string
  default     = "terraform"
}
