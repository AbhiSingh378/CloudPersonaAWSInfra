variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "bucket_arn" {
  description = "ARN of the S3 bucket"
  type        = string
}

variable "db_credentials_secret_arn" {
  description = "ARN of the database credentials secret"
  type        = string
}

variable "lambda_email_credentials_secret_arn" {
  description = "ARN of the Lambda email credentials secret"
  type        = string
}

variable "ec2_key_arn" {
  description = "ARN of the KMS key used for EC2 encryption"
  type        = string
}

variable "rds_key_arn" {
  description = "ARN of the KMS key used for RDS encryption"
  type        = string
}

variable "s3_key_arn" {
  description = "ARN of the KMS key used for S3 encryption"
  type        = string
}

variable "secrets_manager_key_arn" {
  description = "ARN of the KMS key used for Secrets Manager"
  type        = string
}