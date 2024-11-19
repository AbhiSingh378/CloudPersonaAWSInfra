output "instance_profile_name" {
  value = aws_iam_instance_profile.ec2_profile.name
}

# In modules/iam/outputs.tf
output "instance_profile_arn" {
  description = "ARN of the instance profile"
  value       = aws_iam_instance_profile.ec2_profile.arn
}

output "ec2_role_arn" {
  description = "ARN of the EC2 IAM role"
  value       = aws_iam_role.ec2_role.arn
}