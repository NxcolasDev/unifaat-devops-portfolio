variable "aws_region" {
  description = "Regiao AWS da atividade."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto usado em recursos e tags."
  type        = string
  default     = "technova"
}

variable "vpc_cidr" {
  description = "Bloco CIDR da VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "Subnets publicas distribuidas entre AZs."
  type = map(object({
    cidr = string
    az   = string
  }))
  default = {
    az1 = { cidr = "10.0.1.0/24", az = "us-east-1a" }
    az2 = { cidr = "10.0.3.0/24", az = "us-east-1b" }
  }
}

variable "private_subnets" {
  description = "Subnets privadas distribuidas entre AZs."
  type = map(object({
    cidr = string
    az   = string
  }))
  default = {
    az1 = { cidr = "10.0.2.0/24", az = "us-east-1a" }
    az2 = { cidr = "10.0.4.0/24", az = "us-east-1b" }
  }
}

variable "ssh_ingress_cidr" {
  description = "CIDR autorizado para SSH. Restrinja ao IP publico do aluno."
  type        = string
  default     = "0.0.0.0/0"
}

variable "public_key_path" {
  description = "Caminho para a chave publica SSH."
  type        = string
  default     = "~/.ssh/technova-key.pub"
}

variable "user_data_path" {
  description = "Caminho para o script de inicializacao da EC2."
  type        = string
  default     = "user_data.sh"
}
