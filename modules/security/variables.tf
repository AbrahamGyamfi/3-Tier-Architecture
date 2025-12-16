
# VPC ID
variable "vpc_id" {
  description = "VPC ID where the security groups will be created"
  type        = string
}

# Web SG name
variable "web_sg_name" {
  description = "Name for the web security group"
  type        = string
  default     = "web-sg"
}

# App SG name
variable "app_sg_name" {
  description = "Name for the app security group"
  type        = string
  default     = "app-sg"
}

# DB SG name
variable "db_sg_name" {
  description = "Name for the db security group"
  type        = string
  default     = "db-sg"
}

# Tagging variables
variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "dev"
}

variable "project" {
  description = "Project tag"
  type        = string
  default     = "3tier-iac"
}

variable "owner" {
  description = "Owner tag"
  type        = string
  default     = "your_name"
}