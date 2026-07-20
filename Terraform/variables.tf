variable "project_name" {
  description = "Project name prefix used for resource naming"
  type        = string
  default     = "fastapi-demo"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region to deploy into"
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

variable "map_public_ip_on_launch" {
  description = "Whether subnets should auto-assign public IPs"
  type        = bool
  default     = true
}

variable "desired_count" {
  description = "Desired number of ECS tasks for the service"
  type        = number
  default     = 1
}

variable "container_port" {
  description = "Container port the application listens on"
  type        = number
  default     = 8000
}

variable "container_cpu" {
  description = "CPU units for the container"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Memory (MB) for the container"
  type        = number
  default     = 512
}

variable "health_check_path" {
  description = "HTTP health check path for the ALB target group"
  type        = string
  default     = "/health"
}

variable "health_check_port" {
  description = "Health check port for the ALB target group"
  type        = string
  default     = "traffic-port"
}

variable "health_check_interval_seconds" {
  description = "Interval between health checks (seconds)"
  type        = number
  default     = 30
}

variable "healthy_threshold" {
  description = "Healthy threshold count for target group health checks"
  type        = number
  default     = 2
}

variable "unhealthy_threshold" {
  description = "Unhealthy threshold count for target group health checks"
  type        = number
  default     = 3
}
