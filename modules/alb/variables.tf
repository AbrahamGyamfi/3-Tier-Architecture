# ALB Module: variables.tf

variable "alb_name" {
  description = "Name for the ALB"
  type        = string
  default     = "3tier-alb"
}

variable "target_group_name" {
  description = "Name for the target group"
  type        = string
  default     = "3tier-tg"
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

variable "web_sg_id" {
  description = "Web security group ID for ALB"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
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
