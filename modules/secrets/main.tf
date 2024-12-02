# RDS Secrets
resource "aws_secretsmanager_secret" "rds_secrets" {
  name       = "${var.environment}/database-credentials-${var.counter}"
  kms_key_id = var.kms_key_arn
}

resource "aws_secretsmanager_secret_version" "rds_secrets" {
  secret_id = aws_secretsmanager_secret.rds_secrets.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    host     = var.db_host
  })
}

# Email Service Secrets
resource "aws_secretsmanager_secret" "email_secrets" {
  name       = "${var.environment}/email-service-credentials-${var.counter}"
  kms_key_id = var.kms_key_arn
}

resource "aws_secretsmanager_secret_version" "email_secrets" {
  secret_id = aws_secretsmanager_secret.email_secrets.id
  secret_string = jsonencode({
    sender_email      = var.sender_email
    sendgrid_api_key  = var.sendgrid_api_key
    SECRET_TOKEN       = var.SECRET_TOKEN
    verification_url  = var.verification_url
  })
}