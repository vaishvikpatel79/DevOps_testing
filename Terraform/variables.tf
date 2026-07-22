variable "project_name" {
  description = "Project name prefix used in resource names and tags."
  type        = string
  default     = "fastapi-demo"
}

variable "environment" {
  description = "Deployment environment (used in names and tags)."
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_dns_support" {
  description = "Enable DNS support for the VPC."
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames for the VPC."
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
  description = "Whether to auto-assign public IPs in public subnet 1."
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
  description = "Whether to auto-assign public IPs in public subnet 2."
  type        = bool
  default     = true
}

variable "internet_gateway_enabled" {
  description = "Whether to create an Internet Gateway for the VPC."
  type        = bool
  default     = true
}

variable "alb_ingress_port" {
  description = "Port for the ALB listener (HTTP)."
  type        = number
  default     = 80
}

variable "ecs_service_port" {
  description = "Port on which the ECS service container listens."
  type        = number
  default     = 8000
}

variable "ecs_desired_count" {
  description = "Desired number of ECS tasks for the service."
  type        = number
  default     = 1
}

variable "container_cpu" {
  description = "CPU units allocated to the container (Fargate task)."
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Memory (MB) allocated to the container (Fargate task)."
  type        = number
  default     = 512
}

variable "container_port" {
  description = "Container port exposed by the application."
  type        = number
  default     = 8000
}

variable "health_check_path" {
  description = "HTTP health check path for the target group."
  type        = string
  default     = "/health"
}

variable "health_check_interval" {
  description = "Interval (seconds) between health checks for the target group."
  type        = number
  default     = 30
}

variable "health_check_healthy_threshold" {
  description = "Healthy threshold count for target group health checks."
  type        = number
  default     = 2
}

variable "health_check_unhealthy_threshold" {
  description = "Unhealthy threshold count for target group health checks."
  type        = number
  default     = 3
}

variable "health_check_protocol" {
  description = "Protocol used for the target group health check."
  type        = string
  default     = "HTTP"
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
