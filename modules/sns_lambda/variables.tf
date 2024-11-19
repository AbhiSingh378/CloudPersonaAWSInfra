# modules/sns_lambda/variables.tf

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "lambda_function_path" {
  description = "Path to the Lambda function zip file"
  type        = string
}

variable "lambda_handler" {
  description = "Lambda function handler"
  type        = string
  default     = "index.handler"
}

variable "lambda_runtime" {
  description = "Lambda function runtime"
  type        = string
  default     = "python3.9"
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 20
}

variable "lambda_memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 256
}

variable "db_host" {
  description = "Database host"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "verification_url" {
  description = "Base URL for email verification"
  type        = string
}

variable "sender_email" {
  description = "Sender email address for verification emails"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where Lambda will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for Lambda VPC config"
  type        = list(string)
}

variable "rds_arn" {
  description = "RDS instance ARN"
  type        = string
}

variable "ec2_role_arn" {
  description = "EC2 IAM role ARN"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default     = {}
}

# In modules/sns_lambda/variables.tf

variable "sendgrid_api_key" {
  description = "SendGrid API Key for sending emails"
  type        = string
  sensitive   = true
}

variable "domain_name" {
  description = "Domain name"
  type        = string
}
