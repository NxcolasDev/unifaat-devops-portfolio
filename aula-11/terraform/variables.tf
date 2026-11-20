variable "aws_region" {
  description = "AWS region used by the Learner Lab."
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC that contains the existing stable and canary instances."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnets in at least two Availability Zones."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_ids) >= 2
    error_message = "The Application Load Balancer requires subnets in at least two Availability Zones."
  }
}

variable "stable_instance_id" {
  description = "Existing EC2 instance running the stable API."
  type        = string
}

variable "canary_instance_id" {
  description = "Existing EC2 instance running the canary API."
  type        = string
}

variable "instance_port" {
  description = "Port exposed by the API containers."
  type        = number
  default     = 3000
}

variable "health_check_path" {
  description = "Health endpoint exposed by the API."
  type        = string
  default     = "/health"
}

variable "stable_weight" {
  description = "Initial percentage of requests routed to the stable target group."
  type        = number
  default     = 100

  validation {
    condition     = var.stable_weight >= 0 && var.stable_weight <= 100
    error_message = "stable_weight must be between 0 and 100."
  }
}

variable "canary_weight" {
  description = "Initial percentage of requests routed to the canary target group."
  type        = number
  default     = 0

  validation {
    condition     = var.canary_weight >= 0 && var.canary_weight <= 100
    error_message = "canary_weight must be between 0 and 100."
  }
}

variable "tags" {
  description = "Tags applied to the load balancer resources."
  type        = map(string)
  default = {
    Project     = "TechNova"
    Environment = "aula-11"
    ManagedBy   = "Terraform"
  }
}
