variable "name" {
  type        = string
  description = "Nome do Security Group"
}

variable "vpc_id" {
  type        = string
  description = "ID da VPC"
}

variable "environment" {
  type        = string
  description = "Ambiente"
}

variable "project_name" {
  type        = string
  description = "Nome do projeto"
}

variable "ingress_rules" {
  type = list(object({
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string))
    security_groups = optional(list(string))
    description     = optional(string)
  }))
  default     = []
  description = "Lista de regras de entrada"
}