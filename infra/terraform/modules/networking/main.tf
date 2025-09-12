##########################
# File: infra/terraform/modules/networking/main.tf
##########################

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Terraform module to provision VPC networking (VPC, public subnets, Internet Gateway, route table, routes, associations).
# This module is designed to create a basic public network infrastructure in a specified AWS region.

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true # ensure instances can resolve DNS names
  enable_dns_support   = true # ensure DNS resolution is supported
  tags = {
    # "Name" tag includes environment for identification
    Name = "${var.environment}-vpc"
  }
}

# Data source to fetch available AZs in the region (to spread subnets across AZs)
data "aws_availability_zones" "available" {
  state = "available"
}

# Two public subnets, each in a different availability zone.
resource "aws_subnet" "public" {
  count                   = 2 # create two subnets
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true # auto-assign public IPs to instances launched in these subnets
  tags = {
    Name = "${var.environment}-public-subnet-${count.index + 1}"
  }
}

# Internet Gateway to enable internet access for the VPC
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.environment}-igw"
  }
}

# Public route table for the VPC (routes traffic to Internet Gateway)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  # Define a default route sending all IPv4 traffic to the Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "${var.environment}-public-rt"
  }
}

# Associate each public subnet with the public route table (to make them public)
resource "aws_route_table_association" "public_association" {
  count          = 2 # one association per subnet
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
