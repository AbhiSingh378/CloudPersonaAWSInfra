variable "counter" {
  description = "Current counter"
  type        = number
}

variable "environment" {
  description = "Environment name (dev/demo)"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of KMS key for secrets encryption"
  type        = string
}

# RDS Variables
variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_host" {
  description = "Database host"
  type        = string
}

# Email Service Variables
variable "sender_email" {
  description = "Sender email address"
  type        = string
}

variable "sendgrid_api_key" {
  description = "SendGrid API key"
  type        = string
  sensitive   = true
}

variable "SECRET_TOKEN" {
  description = "Secret token for application authentication"
  type        = string
  default     = "d2e26e8a1706c4c4509c4b5757efa58aac898cccf01a8030"
}


variable "verification_url" {
  description = "User verification URL"
  type        = string
}