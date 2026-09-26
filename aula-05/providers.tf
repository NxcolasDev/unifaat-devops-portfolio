terraform {
  required_version = ">= 1.0"

  backend "s3" {
    bucket         = "nxcolasdev-technova-state-f105195a"
    key            = "aula-05/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "nxcolasdev-technova-locks"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "TechNova"
      Environment = "development"
      ManagedBy   = "Terraform"
      Aula        = "05"
      Owner       = "6325171"
    }
  }
}
