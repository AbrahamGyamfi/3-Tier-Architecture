# VPC ID
output "vpc_id" {
  value = aws_vpc.Abraham.id
}

# Public subnet IDs
output "public_subnet_ids" {
  value = [for i in aws_subnet.public : i.id]
}

# Private app subnet IDs
output "private_app_subnet_ids" {
  value = [for i in aws_subnet.private_app : i.id]
}

# Private DB subnet IDs
output "private_db_subnet_ids" {
  value = [for i in aws_subnet.private_db : i.id]
}

# Public route table ID
output "public_route_table_id" {
  value = aws_route_table.public.id
}

# App route table IDs
output "app_route_table_ids" {
  value = [for r in aws_route_table.app : r.id]
}

# DB route table IDs
output "db_route_table_ids" {
  value = [for r in aws_route_table.db : r.id]
}