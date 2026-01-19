
locals {
  environment = var.environment
  project     = var.project
  owner       = var.owner
}

# KMS - Encryption Keys
module "kms" {
  source      = "./modules/kms"
  environment = local.environment
  project     = local.project
  owner       = local.owner
}

# Secrets Manager - Database Credentials
module "secrets" {
  source      = "./modules/secrets"
  project     = local.project
  environment = local.environment
  owner       = local.owner
  db_username = var.db_username
  db_name     = "mydb"
  kms_key_id  = module.kms.secrets_kms_key_id
  depends_on  = [module.kms]
}

# Networking
module "networking" {
  source                   = "./modules/networking"
  azs                      = var.azs
  vpc_cidr                 = var.vpc_cidr
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs
  environment              = local.environment
  project                  = local.project
  owner                    = local.owner
}

# Security
module "security" {
  source      = "./modules/security"
  vpc_id      = module.networking.vpc_id
  web_sg_name = "web-sg"
  app_sg_name = "app-sg"
  db_sg_name  = "db-sg"
  environment = local.environment
  project     = local.project
  owner       = local.owner
  depends_on  = [module.networking]
}

# IAM - Roles for EC2 instances
module "iam" {
  source               = "./modules/iam"
  project              = local.project
  environment          = local.environment
  owner                = local.owner
  secrets_manager_arn  = module.secrets.secret_arn
  kms_key_arn          = module.kms.secrets_kms_key_arn
  depends_on           = [module.secrets, module.kms]
}

# ALB
module "alb" {
  source            = "./modules/alb"
  alb_name          = "3tier-alb"
  target_group_name = "3tier-tg"
  public_subnet_ids = module.networking.public_subnet_ids
  web_sg_id         = module.security.web_sg_id
  vpc_id            = module.networking.vpc_id
  certificate_arn   = var.certificate_arn
  environment       = local.environment
  project           = local.project
  owner             = local.owner
  depends_on        = [module.security, module.networking]
}

# Database
module "database" {
  source               = "./modules/database"
  db_identifier        = "db-3tier"
  engine               = "mysql"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  username             = module.secrets.db_username
  password             = module.secrets.db_password
  db_subnet_group_name = "db-subnet-group-3tier"
  db_subnet_ids        = module.networking.private_db_subnet_ids
  db_sg_id             = module.security.db_sg_id
  kms_key_id           = module.kms.rds_kms_key_arn
  environment          = local.environment
  project              = local.project
  owner                = local.owner
  depends_on           = [module.security, module.networking, module.kms, module.secrets]
}

# Compute (ASG + Launch Template, t3.micro)
module "compute" {
  source                     = "./modules/compute"
  private_app_subnet_ids     = module.networking.private_app_subnet_ids
  security_group_id          = module.security.app_sg_id
  target_group_arns          = [module.alb.target_group_arn]
  asg_min_size               = 2
  asg_max_size               = 2
  asg_desired_capacity       = 2
  db_endpoint                = module.database.address
  db_name                    = "mydb"
  db_username                = module.secrets.db_username
  db_password                = module.secrets.db_password
  iam_instance_profile_name  = module.iam.ec2_instance_profile_name
  secret_name                = module.secrets.secret_name
  aws_region                 = var.aws_region
  environment                = local.environment
  project                    = local.project
  owner                      = local.owner
  depends_on                 = [module.security, module.networking, module.alb, module.database, module.iam]
}