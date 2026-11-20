variable "aws_region" {
  description = "Learner Lab region."
  type        = string
  default     = "us-east-1"
}

variable "lambda_role_name" {
  description = "Pre-existing IAM role supplied by the Learner Lab."
  type        = string
  default     = "LabRole"
}

variable "bedrock_model_id" {
  description = "Optional Bedrock model ID; leave empty to use deterministic rules."
  type        = string
  default     = ""
}

variable "error5xx_threshold" {
  description = "Fixed number of server errors in one period that triggers an alarm."
  type        = number
  default     = 5
}

variable "alarm_period_seconds" {
  description = "CloudWatch alarm evaluation period."
  type        = number
  default     = 60
}

variable "tags" {
  type = map(string)
  default = {
    Project     = "TechNova"
    Environment = "aula-12"
    ManagedBy   = "Terraform"
  }
}
