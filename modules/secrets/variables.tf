# Secrets Manager Module: variables.tf

variable "project" {
  description = "Project name for naming resources"
  type        = string
  default     = "3tier-iac"
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Owner tag"
  type        = string
  default     = "team"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "admin"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "mydb"
}

variable "kms_key_id" {
  description = "KMS key ID for encrypting secrets"
  type        = string
}
