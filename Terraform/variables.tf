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

variable "project_name" {
  description = "Project name used for resource naming."
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

variable "desired_count" {
  description = "Desired number of ECS tasks for the service."
  type        = number
  default     = 1
}
