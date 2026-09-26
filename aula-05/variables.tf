variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "nxcolasdev-technova"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_key_path" {
  type    = string
  default = "~/.ssh/technova-key.pub"
}

variable "ssh_ingress_cidr" {
  description = "IP/CIDR autorizado para SSH. Restrinja ao seu IP publico."
  type        = string
  default     = "0.0.0.0/0"
}

variable "db_name" {
  type    = string
  default = "technova"
}

variable "db_username" {
  type    = string
  default = "technova_admin"
}

variable "db_password" {
  type      = string
  sensitive = true
}