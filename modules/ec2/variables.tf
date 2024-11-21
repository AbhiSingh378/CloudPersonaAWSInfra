variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs of public subnets"
  type        = list(string)
}

variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "db_endpoint" {
  description = "RDS instance endpoint"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "iam_instance_profile" {
  description = "IAM instance profile name"
  type        = string
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID"
  type        = string
}

variable "domain_name" {
  description = "Domain name"
  type        = string
}

variable "environment" {
  description = "Environment (dev/demo)"
  type        = string
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

# In modules/ec2/variables.tf
variable "sns_topic_arn" {
  description = "ARN of the SNS topic"
  type        = string
}

variable "key_name" {
  description = "ARN of the SNS topic"
  type        = string
}

variable "SECRET_TOKEN" {
  description = "Secret token for application authentication"
  type        = string
  default     = "d2e26e8a1706c4c4509c4b5757efa58aac898cccf01a8030"
}