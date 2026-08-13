variable "project_id" {
  description = "The GCP project id to deploy resources into. Required."
  type        = string
}

variable "project_name" {
  description = "Logical project name used as a naming prefix."
  type        = string
  default     = "fastapi-demo"
}

variable "environment" {
  description = "Deployment environment (used in names and labels)."
  type        = string
  default     = "dev"
}

variable "region" {
  description = "GCP region to deploy regional resources to."
  type        = string
  default     = "us-east1"
}

variable "service_account_id" {
  description = "Service account account_id (local part) used by Cloud Run."
  type        = string
  default     = "fastapi-demo-run-sa"
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
