variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "s3_kms_key_arn" {
  description = "ARN of KMS key for S3 bucket encryption"
  type        = string
}