variable "project_id" {
  description = "GCP project id to deploy into"
  type        = string
}

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
  description = "GCP region to deploy resources into"
  type        = string
  default     = "us-east1"
}

variable "service_tags" {
  description = "Map of service name to image tag. Terraform constructs full Artifact Registry URIs from this map."
  type        = map(string)
  default     = {}
}

variable "service_repositories" {
  description = "Map of logical service name to container repository name."
  type        = map(string)
  default     = {}
}

variable "artifact_registry_repository" {
  description = "Artifact Registry repository name. Defaults to the project name (e.g. \"ecommerce-platform\")."
  type        = string
  default     = "fastapi-demo"
}

variable "cloud_run_service_name" {
  description = "Cloud Run service name"
  type        = string
  default     = "fastapi-demo-service"
}

variable "service_account_name" {
  description = "Service account account_id for Cloud Run service"
  type        = string
  default     = "fastapi-demo-run-sa"
}

variable "subnet_cidr" {
  description = "CIDR range for the app subnetwork"
  type        = string
  default     = "10.0.0.0/24"
}

variable "vpc_connector_ip_cidr" {
  description = "IP CIDR range for the Serverless VPC Access connector"
  type        = string
  default     = "10.8.0.0/28"
}

variable "container_port" {
  description = "Container port exposed by the service"
  type        = number
  default     = 8000
}

variable "container_cpu" {
  description = "Requested CPU for the container (as string for Cloud Run requests)"
  type        = string
  default     = "1"
}

variable "container_memory" {
  description = "Requested memory for the container (as string for Cloud Run requests)"
  type        = string
  default     = "512Mi"
}

variable "health_path" {
  description = "Liveness probe path for the service"
  type        = string
  default     = "/health"
}

variable "health_check_interval" {
  description = "Interval seconds for the health check probe"
  type        = number
  default     = 30
}
