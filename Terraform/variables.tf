variable "project_name" {
  description = "Project name used as prefix for resource names"
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
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_enable_dns_support" {
  description = "Whether to enable DNS support on the VPC"
  type        = bool
  default     = true
}

variable "vpc_enable_dns_hostnames" {
  description = "Whether to enable DNS hostnames on the VPC"
  type        = bool
  default     = true
}

variable "public_subnet_1_cidr" {
  description = "CIDR for public subnet 1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_1_az" {
  description = "Availability zone for public subnet 1"
  type        = string
  default     = "us-east-1a"
}

variable "public_subnet_1_map_public_ip_on_launch" {
  description = "Whether to auto assign public IP for subnet 1"
  type        = bool
  default     = true
}

variable "public_subnet_2_cidr" {
  description = "CIDR for public subnet 2"
  type        = string
  default     = "10.0.2.0/24"
}

variable "public_subnet_2_az" {
  description = "Availability zone for public subnet 2"
  type        = string
  default     = "us-east-1b"
}

variable "public_subnet_2_map_public_ip_on_launch" {
  description = "Whether to auto assign public IP for subnet 2"
  type        = bool
  default     = true
}

variable "alb_listener_port" {
  description = "Port for the ALB listener"
  type        = number
  default     = 80
}

variable "container_port" {
  description = "Container application port"
  type        = number
  default     = 8000
}

variable "desired_task_count" {
  description = "Desired number of ECS tasks for the service"
  type        = number
  default     = 1
}

variable "task_cpu" {
  description = "CPU units for the ECS task"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Memory (MB) for the ECS task"
  type        = number
  default     = 512
}

variable "health_check_path" {
  description = "Health check path for the target group"
  type        = string
  default     = "/health"
}

variable "health_check_protocol" {
  description = "Health check protocol for the target group"
  type        = string
  default     = "HTTP"
}

variable "health_check_port" {
  description = "Health check port for the target group"
  type        = string
  default     = "traffic-port"
}

variable "health_check_healthy_threshold" {
  description = "Healthy threshold count for the target group health check"
  type        = number
  default     = 2
}

variable "health_check_unhealthy_threshold" {
  description = "Unhealthy threshold count for the target group health check"
  type        = number
  default     = 3
}

variable "health_check_interval_seconds" {
  description = "Health check interval seconds for the target group"
  type        = number
  default     = 30
}
