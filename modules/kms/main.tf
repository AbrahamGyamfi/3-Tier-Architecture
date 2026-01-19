# KMS Module: main.tf
# Creates KMS keys for encrypting RDS, Secrets Manager, and other services

locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
  }
}

# KMS Key for RDS Encryption
resource "aws_kms_key" "rds" {
  description             = "KMS key for RDS encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = merge({
    Name = "${var.project}-rds-kms-key"
    Purpose = "RDS Encryption"
  }, local.common_tags)
}

resource "aws_kms_alias" "rds" {
  name          = "alias/${var.project}-rds"
  target_key_id = aws_kms_key.rds.key_id
}

# KMS Key for Secrets Manager
resource "aws_kms_key" "secrets" {
  description             = "KMS key for Secrets Manager encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = merge({
    Name = "${var.project}-secrets-kms-key"
    Purpose = "Secrets Manager Encryption"
  }, local.common_tags)
}

resource "aws_kms_alias" "secrets" {
  name          = "alias/${var.project}-secrets"
  target_key_id = aws_kms_key.secrets.key_id
}

# KMS Key for EBS Volumes (optional, for EC2 instance encryption)
resource "aws_kms_key" "ebs" {
  description             = "KMS key for EBS volume encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = merge({
    Name = "${var.project}-ebs-kms-key"
    Purpose = "EBS Encryption"
  }, local.common_tags)
}

resource "aws_kms_alias" "ebs" {
  name          = "alias/${var.project}-ebs"
  target_key_id = aws_kms_key.ebs.key_id
}
