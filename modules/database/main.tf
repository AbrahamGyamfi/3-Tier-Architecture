# Database Module: main.tf

locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
  }
}

resource "aws_db_subnet_group" "Ab" {
  name       = var.db_subnet_group_name
  subnet_ids = var.db_subnet_ids
  tags = merge({
    Name = var.db_subnet_group_name
  }, local.common_tags)
}

resource "aws_db_instance" "Ab" {
  identifier             = var.db_identifier
  engine                 = var.engine
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  db_subnet_group_name   = aws_db_subnet_group.Ab.name
  vpc_security_group_ids = [var.db_sg_id]
  username               = var.username
  password               = var.password
  skip_final_snapshot    = true
  publicly_accessible    = false
  multi_az               = false
  tags = merge({
    Name = var.db_identifier
  }, local.common_tags)
}
