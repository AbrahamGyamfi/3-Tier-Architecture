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