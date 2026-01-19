# IAM Module: variables.tf

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

variable "secrets_manager_arn" {
  description = "ARN of the Secrets Manager secret for database credentials"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for decrypting secrets"
  type        = string
}
