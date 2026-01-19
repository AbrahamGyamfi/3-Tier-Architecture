# Database Module: main.tf

locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
  }
}

resource "aws_db_subnet_group" "main" {
  name       = var.db_subnet_group_name
  subnet_ids = var.db_subnet_ids
  tags = merge({
    Name = var.db_subnet_group_name
  }, local.common_tags)
}

resource "aws_db_instance" "main" {
  identifier             = var.db_identifier
  engine                 = var.engine
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.db_sg_id]
  username               = var.username
  password               = var.password
  skip_final_snapshot    = true
  publicly_accessible    = false
  multi_az               = false
  storage_encrypted      = true
  kms_key_id             = var.kms_key_id
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "mon:04:00-mon:05:00"
  tags = merge({
    Name = var.db_identifier
  }, local.common_tags)
}

# Read Replica in another availability zone
resource "aws_db_instance" "replica" {
  identifier             = "${var.db_identifier}-replica"
  replicate_source_db    = aws_db_instance.main.identifier
  instance_class         = var.instance_class
  skip_final_snapshot    = true
  publicly_accessible    = false
  storage_encrypted      = true
  kms_key_id             = var.kms_key_id
  tags = merge({
    Name = "${var.db_identifier}-replica"
    Role = "read-replica"
  }, local.common_tags)
}
