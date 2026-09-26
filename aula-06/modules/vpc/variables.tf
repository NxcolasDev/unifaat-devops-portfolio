variable "vpc_cidr" {
  type        = string
  description = "CIDR block da VPC"
}

variable "project_name" {
  type        = string
  description = "Nome do projeto"
}

variable "environment" {
  type        = string
  description = "Ambiente (dev, staging, prod)"
}

variable "subnets" {
  type = map(object({
    cidr = string
    az   = string
    type = string # "public" ou "private"
  }))
  description = "Mapa de subnets"
}