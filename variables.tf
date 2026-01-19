# Root variables.tf for 3-tier project

variable "aws_region" {
  description = "AWS region to deploy (eu-west-1, eu-central-1, us-east-1 only)"
  type        = string
  default     = "eu-west-1"
  validation {
    condition     = contains(["eu-west-1", "eu-central-1", "us-east-1"], var.aws_region)
    error_message = "Region must be eu-west-1, eu-central-1, or us-east-1."
  }
}

variable "azs" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b"]
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_app_subnet_cidrs" {
  description = "List of private app subnet CIDRs"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "private_db_subnet_cidrs" {
  description = "List of private DB subnet CIDRs"
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24"]
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
  default     = "your_name"
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  default     = "admin"
}

variable "certificate_arn" {
  description = "ARN of ACM certificate for HTTPS (optional - leave empty to use HTTP only)"
  type        = string
  default     = ""
}
