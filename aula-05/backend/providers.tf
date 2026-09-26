terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "TechNova"
      ManagedBy = "Terraform"
      Aula      = "05"
      Owner     = "6325171"
      Purpose   = "Terraform Remote State"
    }
  }
}