# Common tags local
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
  }
}

# Web Security Group (for ALB/public)
resource "aws_security_group" "web" {
  name        = var.web_sg_name
  description = "Web/ALB SG: Allow HTTP, ICMP, and health checks"
  vpc_id      = var.vpc_id
  tags = merge({
    Name = var.web_sg_name
    Tier = "web"
  }, local.common_tags)
}

# Allow HTTP from anywhere
resource "aws_vpc_security_group_ingress_rule" "web_http" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# Allow HTTPS from anywhere
resource "aws_vpc_security_group_ingress_rule" "web_https" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

# Allow ICMP (ping) from anywhere
resource "aws_vpc_security_group_ingress_rule" "web_icmp" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = -1
  ip_protocol       = "icmp"
  to_port           = -1
}
# Allow all outbound
resource "aws_vpc_security_group_egress_rule" "web_all" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# App Security Group (for EC2/app tier)
resource "aws_security_group" "app" {
  name        = var.app_sg_name
  description = "App SG: Allow HTTP from ALB/Web SG, ICMP from Web SG, all egress"
  vpc_id      = var.vpc_id
  tags = merge({
    Name = var.app_sg_name
    Tier = "app"
  }, local.common_tags)
}
# Allow HTTP from Web SG
resource "aws_vpc_security_group_ingress_rule" "app_http" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.web.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}
# Allow ICMP from Web SG
resource "aws_vpc_security_group_ingress_rule" "app_icmp" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.web.id
  from_port                    = -1
  ip_protocol                  = "icmp"
  to_port                      = -1
}
# Allow all outbound
resource "aws_vpc_security_group_egress_rule" "app_all" {
  security_group_id = aws_security_group.app.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# DB Security Group (for RDS)
resource "aws_security_group" "db" {
  name        = var.db_sg_name
  description = "DB SG: Allow DB port from App SG, ICMP from App SG, all egress"
  vpc_id      = var.vpc_id
  tags = merge({
    Name = var.db_sg_name
    Tier = "db"
  }, local.common_tags)
}
# Allow DB port (MySQL 3306) from App SG
resource "aws_vpc_security_group_ingress_rule" "db_mysql" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306
}
# Allow ICMP from App SG
resource "aws_vpc_security_group_ingress_rule" "db_icmp" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = -1
  ip_protocol                  = "icmp"
  to_port                      = -1
}
# Allow all outbound
resource "aws_vpc_security_group_egress_rule" "db_all" {
  security_group_id = aws_security_group.db.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}