
# Creating VPC
resource "aws_vpc" "Abraham" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  # tags = merge({
  #   Name = "3tier-vpc"
  # }, local.common_tags)
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.Abraham.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true
  # tags = merge({
  #   Name = "3tier-public-${count.index + 1}"
  #   Tier = "public"
  # }, local.common_tags)
}

# Private App Subnets
resource "aws_subnet" "private_app" {
  count             = length(var.private_app_subnet_cidrs)
  vpc_id            = aws_vpc.Abraham.id
  cidr_block        = var.private_app_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]
  tags = {
    Name = "app-${count.index + 1}"
  }
}

# Private DB Subnets
resource "aws_subnet" "private_db" {
  count             = length(var.private_db_subnet_cidrs)
  vpc_id            = aws_vpc.Abraham.id
  cidr_block        = var.private_db_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]
  tags = merge({
    Name = "3tier-db-${count.index + 1}"
  }, local.common_tags)
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.Abraham.id
  tags = merge({
    Name = "3tier-igw"
  }, local.common_tags)
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  count = length(var.azs)
  tags = merge({
    Name = "3tier-nat-eip-${count.index + 1}"
  }, local.common_tags)
}

# NAT Gateway (one per AZ for HA)
resource "aws_nat_gateway" "nat" {
  count         = length(var.azs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags = merge({
    Name = "3tier-natgw-${count.index + 1}"
  }, local.common_tags)
  depends_on = [aws_internet_gateway.igw]
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.Abraham.id
  route {
    cidr_block = var.default_route_cidr
    gateway_id = aws_internet_gateway.igw.id
  }

}

# Associate public subnets with public route table
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# App Route Tables (one per AZ)
resource "aws_route_table" "app" {
  count  = length(var.azs)
  vpc_id = aws_vpc.Abraham.id
  route {
    cidr_block     = var.default_route_cidr
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }
  tags = merge({
    Name = "3tier-app-rtb-${count.index + 1}"
  }, local.common_tags)
}

# Associate app subnets with app route tables
resource "aws_route_table_association" "app" {
  count          = length(var.private_app_subnet_cidrs)
  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.app[count.index].id
}

# DB Route Tables (private, no outbound route)
resource "aws_route_table" "db" {
  count  = length(var.azs)
  vpc_id = aws_vpc.Abraham.id
  tags = merge({
    Name = "3tier-db-rtb-${count.index + 1}"
  }, local.common_tags)
}

# Associate db subnets with db route tables
resource "aws_route_table_association" "db" {
  count          = length(var.private_db_subnet_cidrs)
  subnet_id      = aws_subnet.private_db[count.index].id
  route_table_id = aws_route_table.db[count.index].id
}

# Common tags local
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
  }
}