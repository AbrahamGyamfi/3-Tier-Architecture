# Database Module: outputs.tf

output "address" {
  description = "RDS endpoint address"
  value       = aws_db_instance.Ab.address
}

output "port" {
  description = "RDS port"
  value       = aws_db_instance.Ab.port
}
