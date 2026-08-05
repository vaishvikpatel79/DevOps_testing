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

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames on the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS resolution on the VPC"
  type        = bool
  default     = true
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

variable "task_desired_count" {
  description = "Desired number of ECS tasks for the service"
  type        = number
  default     = 1
}

variable "container_cpu_units" {
  description = "CPU units for the container"
  type        = number
  default     = 256
}

variable "container_memory_mb" {
  description = "Memory (MB) for the container"
  type        = number
  default     = 512
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 8000
}

variable "health_check_path" {
  description = "HTTP health check path for the target group"
  type        = string
  default     = "/health"
}

variable "health_check_protocol" {
  description = "Protocol used by the target group health check"
  type        = string
  default     = "HTTP"
}

variable "health_check_port" {
  description = "Health check port for the target group (use 'traffic-port' or numeric)"
  type        = string
  default     = "traffic-port"
}

variable "healthy_threshold_count" {
  description = "Healthy threshold count for target group health checks"
  type        = number
  default     = 2
}

variable "unhealthy_threshold_count" {
  description = "Unhealthy threshold count for target group health checks"
  type        = number
  default     = 3
}

variable "health_check_interval_seconds" {
  description = "Interval seconds for target group health checks"
  type        = number
  default     = 30
}

variable "alb_port" {
  description = "Port for the Application Load Balancer listener"
  type        = number
  default     = 80
}

variable "managed_by" {
  description = "Tag value for ManagedBy"
  type        = string
  default     = "terraform"
}
