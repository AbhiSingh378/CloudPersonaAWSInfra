variable "vpc_id" {
  description = "ID of the VPC"
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