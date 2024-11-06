output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.subnets.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.subnets.private_subnet_ids
}

output "internet_gateway_id" {
  value = module.internet_gateway.internet_gateway_id
}

output "s3_bucket_name" {
  value = module.s3.bucket_name
}

output "s3_bucket_arn" {
  value = module.s3.bucket_arn
}

# New outputs for ALB and Security Groups
output "app_security_group_id" {
  value = module.ec2.app_security_group_id
}

output "alb_security_group_id" {
  value = module.ec2.alb_security_group_id
}

output "alb_dns_name" {
  value = module.ec2.alb_dns_name
}

output "alb_zone_id" {
  value = module.ec2.alb_zone_id
}

output "target_group_arn" {
  value = module.ec2.target_group_arn
}