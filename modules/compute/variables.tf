# List of private app subnet IDs for ASG
variable "private_app_subnet_ids" {
  description = "List of private app subnet IDs for ASG"
  type        = list(string)
}
# ASG min size
variable "asg_min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
  default     = 1
}

# ASG max size
variable "asg_max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
  default     = 2
}

# ASG desired capacity
variable "asg_desired_capacity" {
  description = "Desired number of instances in ASG"
  type        = number
  default     = 1
}

# Security Group ID
variable "security_group_id" {
  description = "Security Group ID to associate with the instance"
  type        = string
}

# Target group ARNs for ALB attachment
variable "target_group_arns" {
  description = "List of target group ARNs to attach ASG to"
  type        = list(string)
  default     = []
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