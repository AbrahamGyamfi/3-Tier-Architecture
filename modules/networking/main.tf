
# Creating VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge({
    Name = "3tier-vpc"
  }, local.common_tags)
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true
  tags = merge({
    Name = "3tier-public-${count.index + 1}"
    Tier = "public"
  }, local.common_tags)
}

# Private App Subnets
resource "aws_subnet" "private_app" {
  count             = length(var.private_app_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_app_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]
  tags = merge({
    Name = "3tier-app-${count.index + 1}"
    Tier = "app"
  }, local.common_tags)
}

# Private DB Subnets
resource "aws_subnet" "private_db" {
  count             = length(var.private_db_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_db_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]
  tags = merge({
    Name = "3tier-db-${count.index + 1}"
    Tier = "db"
  }, local.common_tags)
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = merge({
    Name = "3tier-igw"
  }, local.common_tags)
}

# Elastic IP for NAT Gateway (single NAT GW for cost optimization)
resource "aws_eip" "nat" {
  tags = merge({
    Name = "3tier-nat-eip"
  }, local.common_tags)
}

# NAT Gateway (single for cost optimization)
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  tags = merge({
    Name = "3tier-natgw"
  }, local.common_tags)
  depends_on = [aws_internet_gateway.igw]
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = var.default_route_cidr
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge({
    Name = "3tier-public-rtb"
  }, local.common_tags)
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# App Route Tables (all use single NAT GW)
resource "aws_route_table" "app" {
  count  = length(var.azs)
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = var.default_route_cidr
    nat_gateway_id = aws_nat_gateway.nat.id
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
  vpc_id = aws_vpc.main.id
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