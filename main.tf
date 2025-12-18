
locals {
  environment = var.environment
  project     = var.project
  owner       = var.owner
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

# ALB
module "alb" {
  source            = "./modules/alb"
  alb_name          = "3tier-alb"
  target_group_name = "3tier-tg"
  public_subnet_ids = module.networking.public_subnet_ids
  web_sg_id         = module.security.web_sg_id
  vpc_id            = module.networking.vpc_id
  environment       = local.environment
  project           = local.project
  owner             = local.owner
  depends_on        = [module.security, module.networking]
}

# Compute (ASG + Launch Template, t3.micro)
module "compute" {
  source                 = "./modules/compute"
  private_app_subnet_ids = module.networking.private_app_subnet_ids
  security_group_id      = module.security.app_sg_id
  target_group_arns      = [module.alb.target_group_arn]
  asg_min_size           = 2
  asg_max_size           = 2
  asg_desired_capacity   = 2
  db_endpoint            = module.database.address
  db_name                = "mydb"
  db_username            = var.db_username
  db_password            = var.db_password
  environment            = local.environment
  project                = local.project
  owner                  = local.owner
  depends_on             = [module.security, module.networking, module.alb, module.database]
}

# Database
module "database" {
  source               = "./modules/database"
  db_identifier        = "db-3tier"
  engine               = "mysql"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  username             = var.db_username
  password             = var.db_password
  db_subnet_group_name = "db-subnet-group-3tier"
  db_subnet_ids        = module.networking.private_db_subnet_ids
  db_sg_id             = module.security.db_sg_id
  environment          = local.environment
  project              = local.project
  owner                = local.owner
  depends_on           = [module.security, module.networking]
}