# Database Module: variables.tf

variable "db_identifier" {
  description = "Identifier for the RDS instance"
  type        = string
  default     = "db-3tier"
}

variable "engine" {
  description = "Database engine (mysql or postgres)"
  type        = string
  default     = "mysql"
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "username" {
  description = "Master username (from Secrets Manager)"
  type        = string
}

variable "password" {
  description = "Master password (from Secrets Manager)"
  type        = string
  sensitive   = true
}

variable "db_subnet_group_name" {
  description = "Name for the DB subnet group"
  type        = string
  default     = "db-subnet-group-3tier"
}

variable "db_subnet_ids" {
  description = "List of private DB subnet IDs"
  type        = list(string)
}

variable "db_sg_id" {
  description = "DB security group ID"
  type        = string
}

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
  default     = "Ab"
}

variable "kms_key_id" {
  description = "KMS key ID for RDS encryption"
  type        = string
}
