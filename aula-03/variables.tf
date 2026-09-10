variable "aws_region" {
  description = "Regiao AWS usada pela atividade."
  type        = string
  default     = "us-east-1"
}

variable "ra" {
  description = "RA usado como prefixo para evitar conflitos na conta AWS."
  type        = string
  default     = "6325171"
}

variable "student_name" {
  description = "Nome do aluno usado nas tags dos recursos."
  type        = string
  default     = "Nicolas Jesus e Silva"
}

variable "project_name" {
  description = "Nome do projeto da atividade."
  type        = string
  default     = "TechNova"
}

variable "environment" {
  description = "Ambiente logico dos recursos."
  type        = string
  default     = "lab"
}

locals {
  name_prefix = "${var.ra}-technova"

  common_tags = {
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Aluno       = var.student_name
    RA          = var.ra
    Disciplina  = "DevOps - UniFAAT 2026-2"
    Aula        = "03"
    Environment = var.environment
  }
}