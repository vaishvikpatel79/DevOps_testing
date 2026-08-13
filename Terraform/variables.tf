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
  description = "Deployment environment (e.g. dev, prod)"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "GCP region for regional resources"
  type        = string
  default     = "us-east1"
}

variable "managed_by" {
  description = "Label identifying the manager of these resources"
  type        = string
  default     = "terraform"
}

variable "service_account_id" {
  description = "Service account account_id to create for Cloud Run"
  type        = string
  default     = "fastapi-demo-run-sa"
}

variable "container_cpu" {
  description = "CPU request for the container (Cloud Run). Use same format as Cloud Run expects, e.g. \"1\""
  type        = string
  default     = "1"
}

variable "container_memory" {
  description = "Memory request for the container (Cloud Run), e.g. \"512Mi\""
  type        = string
  default     = "512Mi"
}

variable "container_port" {
  description = "Container listening port"
  type        = number
  default     = 8000
}

variable "min_instances" {
  description = "Minimum number of Cloud Run instances (autoscaling min)"
  type        = number
  default     = 1
}

variable "max_instances" {
  description = "Maximum number of Cloud Run instances (autoscaling max)"
  type        = number
  default     = 1
}

variable "health_check_path" {
  description = "HTTP health check path for backend health checks"
  type        = string
  default     = "/health"
}

variable "health_check_port" {
  description = "Port used by the health check"
  type        = number
  default     = 8000
}

variable "health_check_interval_seconds" {
  description = "Interval seconds for health checks"
  type        = number
  default     = 30
}

variable "subnet_cidr" {
  description = "CIDR range for the app subnetwork"
  type        = string
  default     = "10.0.0.0/24"
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
