resource "aws_kms_key" "ec2_key" {
  description             = "KMS key for EC2 encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 7
  tags = var.tags
}

resource "aws_kms_key" "rds_key" {
  description             = "KMS key for RDS encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 7
  tags = var.tags
}

resource "aws_kms_key" "s3_key" {
  description             = "KMS key for S3 encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 7
  tags = var.tags
}

resource "aws_kms_key" "secrets_key" {
  description             = "KMS key for Secrets Manager"
  enable_key_rotation     = true
  deletion_window_in_days = 7
  tags = var.tags
}

# Create aliases for each key
resource "aws_kms_alias" "ec2_key_alias" {
  name          = "alias/ec2-key-${var.counter}"
  target_key_id = aws_kms_key.ec2_key.key_id
}

resource "aws_kms_alias" "rds_key_alias" {
  name          = "alias/rds-key-${var.counter}"
  target_key_id = aws_kms_key.rds_key.key_id
}

resource "aws_kms_alias" "s3_key_alias" {
  name          = "alias/s3-key-${var.counter}"
  target_key_id = aws_kms_key.s3_key.key_id
}

resource "aws_kms_alias" "secrets_key_alias" {
  name          = "alias/secrets-key-${var.counter}"
  target_key_id = aws_kms_key.secrets_key.key_id
}