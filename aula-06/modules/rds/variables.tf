variable "db_name" {
  type        = string
  description = "Nome do banco de dados"
}

variable "db_username" {
  type        = string
  description = "Usuário master"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Senha master"
}

variable "subnet_ids" {
  type        = list(string)
  description = "IDs das subnets privadas para o DB Subnet Group"
}

variable "security_group_ids" {
  type        = list(string)
  description = "SG IDs para o RDS"
}

variable "instance_class" {
  type        = string
  default     = "db.t3.micro"
  description = "Classe da instância RDS"
}

variable "environment" {
  type        = string
  description = "Ambiente"
}

variable "project_name" {
  type        = string
  description = "Nome do projeto"
}