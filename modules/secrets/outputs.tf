output "rds_secret_arn" {
  value = aws_secretsmanager_secret.rds_secrets.arn
}

output "email_secret_arn" {
  value = aws_secretsmanager_secret.email_secrets.arn
}

output "rds_secret_version" {
  value = aws_secretsmanager_secret_version.rds_secrets.version_id
}

output "email_secret_version" {
  value = aws_secretsmanager_secret_version.email_secrets.version_id
}