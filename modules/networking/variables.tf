# Variables for networking module

# List of availability zones
variable "azs" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b"]
}

# VPC CIDR block
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}


# Public subnet CIDRs (2)
variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

# Private app subnet CIDRs (2)
variable "private_app_subnet_cidrs" {
  description = "List of CIDR blocks for private app subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

# Private DB subnet CIDRs (2)
variable "private_db_subnet_cidrs" {
  description = "List of CIDR blocks for private DB subnets"
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24"]
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
  default     = "Ab"
}

variable "default_route_cidr" {
  description = "Default route CIDR block"
  type        = string
  default     = "0.0.0.0/0"

}
