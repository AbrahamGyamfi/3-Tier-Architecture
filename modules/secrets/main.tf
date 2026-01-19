# Secrets Manager Module: main.tf
# Manages database credentials securely in AWS Secrets Manager

locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
  }
}

# Random password generation
resource "random_password" "db_password" {
  length  = 24
  special = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Store database credentials in Secrets Manager
resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "${var.project}-db-credentials"
  description             = "Database master credentials for RDS MySQL"
  kms_key_id              = var.kms_key_id
  recovery_window_in_days = 7

  tags = merge({
    Name = "${var.project}-db-credentials"
  }, local.common_tags)
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password.result
    engine   = "mysql"
    host     = ""  # Will be updated after RDS creation
    port     = 3306
    dbname   = var.db_name
  })
}
