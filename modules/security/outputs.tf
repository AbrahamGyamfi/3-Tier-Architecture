# Web Security Group ID
output "web_sg_id" {
  value = aws_security_group.web.id
}

# App Security Group ID
output "app_sg_id" {
  value = aws_security_group.app.id
}

# DB Security Group ID
output "db_sg_id" {
  value = aws_security_group.db.id
}