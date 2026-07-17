terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.45.0"
    }
  }

  # backend "s3" {
  #   bucket = "<your-state-bucket>"
  #   key    = "PROJECT/ENV/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

provider "aws" {
  region = var.region
}
