variable "instance_name" {
  type        = string
  description = "Nome da instância"
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "Tipo da instância"
}

variable "ami_id" {
  type        = string
  description = "AMI ID"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID"
}

variable "security_group_ids" {
  type        = list(string)
  description = "Lista de Security Group IDs"
}

variable "key_name" {
  type        = string
  default     = null
  description = "Key pair name"
}

variable "user_data" {
  type        = string
  default     = null
  description = "User data script"
}