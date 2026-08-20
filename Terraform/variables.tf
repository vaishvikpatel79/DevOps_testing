variable "project_id" {
  description = "GCP project ID to deploy resources into. This must be provided by the user."
  type        = string
}

variable "project_name" {
  description = "Logical project name used for resource naming."
  type        = string
  default     = "fastapi-demo"
}

variable "environment" {
  description = "Deployment environment (e.g. dev, prod)."
  type        = string
  default     = "dev"
}

variable "region" {
  description = "GCP region to deploy regional resources into."
  type        = string
  default     = "us-east1"
}

variable "managed_by" {
  description = "Label value indicating the managing system."
  type        = string
  default     = "terraform"
}

variable "service_tags" {
  description = "Map of service name to image tag. Terraform constructs full Artifact Registry URIs from this map."
  type        = map(string)
  default     = {}
}

variable "service_repositories" {
  description = "Map of logical service name to container repository name."
  type        = map(string)
  default     = { "fastapi-demo-service" = "fastapi-demo-service" }
}

variable "artifact_registry_repository" {
  description = "Artifact Registry repository name. Defaults to the project name (e.g. \"ecommerce-platform\")."
  type        = string
  default     = "fastapi-demo"
}

variable "service_account_name" {
  description = "Service account account_id to create for Cloud Run."
  type        = string
  default     = "fastapi-demo-run-sa"
}

variable "subnet_cidr" {
  description = "CIDR range for the app subnetwork."
  type        = string
  default     = "10.0.0.0/24"
}
