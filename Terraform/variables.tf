variable "project_id" {
  description = "GCP project id where resources will be created"
  type        = string
}

variable "project_name" {
  description = "Logical project name used for resource naming"
  type        = string
  default     = "fastapi-demo"
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "GCP region for regional resources"
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
