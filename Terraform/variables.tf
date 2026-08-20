variable "project_id" {
  description = "The GCP project id to deploy into."
  type        = string
}

variable "region" {
  description = "GCP region for regional resources."
  type        = string
  default     = "us-east1"
}

variable "project_name" {
  description = "Project name prefix used in resource names."
  type        = string
  default     = "fastapi-demo"
}

variable "environment" {
  description = "Deployment environment (used in resource names and labels)."
  type        = string
  default     = "dev"
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

variable "service_account_name" {
  description = "Service account account_id to create for Cloud Run (exact account id)."
  type        = string
  default     = "fastapi-demo-run-sa"
}

variable "container_cpu" {
  description = "Container CPU request for Cloud Run (exact value per requirements)."
  type        = string
  default     = "1 CPU"
}

variable "container_memory" {
  description = "Container memory request for Cloud Run (exact value per requirements)."
  type        = string
  default     = "512 Mi"
}

variable "container_port" {
  description = "Container port the application listens on."
  type        = number
  default     = 8000
}
