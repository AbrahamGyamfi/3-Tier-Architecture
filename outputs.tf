# ALB DNS output
output "alb_dns" {
  value = module.alb.alb_dns
}

# RDS endpoint output
output "rds_endpoint" {
  value = module.database.address
}

# ASG name output
output "asg_name" {
  value = module.compute.asg_name
}

# Launch Template ID output
output "launch_template_id" {
  value = module.compute.launch_template_id
}

# Secrets Manager secret name
output "secret_name" {
  value       = module.secrets.secret_name
  description = "Name of the Secrets Manager secret containing DB credentials"
}

# KMS key IDs
output "rds_kms_key_id" {
  value       = module.kms.rds_kms_key_arn
  description = "KMS key ARN used for RDS encryption"
}

# IAM instance profile
output "ec2_instance_profile" {
  value       = module.iam.ec2_instance_profile_name
  description = "IAM instance profile attached to EC2 instances"
}