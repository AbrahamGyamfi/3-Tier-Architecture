# Database Module: outputs.tf

output "address" {
  description = "RDS endpoint address"
  value       = aws_db_instance.main.address
}

output "port" {
  description = "RDS port"
  value       = aws_db_instance.main.port
}

output "replica_address" {
  description = "RDS read replica endpoint address"
  value       = aws_db_instance.replica.address
}

output "replica_port" {
  description = "RDS read replica port"
  value       = aws_db_instance.replica.port
}
