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

# Terraform module to provision VPC networking (VPC, public/private subnets, Internet Gateway, NAT Gateway, route tables, routes, associations).
# This module creates a basic network infrastructure with public and private subnets, supporting internet access via IGW (for public subnets) and NAT (for private subnets).

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true # ensure instances can resolve DNS hostnames
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
  count                   = length(var.public_subnet_cidrs) # create one public subnet per CIDR provided
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = var.map_public_ip_on_launch # auto-assign public IPs to instances launched in these subnets
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

# Public route table for the VPC (routes all outbound traffic from public subnets to the Internet Gateway)
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

# Associate each public subnet with the public route table (making them public)
resource "aws_route_table_association" "public_association" {
  count          = length(var.public_subnet_cidrs) # one association per public subnet
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Two private subnets, each in a different availability zone (private, no direct public IPs).
resource "aws_subnet" "private" {
  count                   = length(var.private_subnet_cidrs) # create one private subnet per CIDR provided
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false # do NOT auto-assign public IPs in private subnets
  tags = {
    Name = "${var.environment}-private-subnet-${count.index + 1}"
  }
}

# Elastic IP for the NAT Gateway (to provide a public IP for outbound traffic from private subnets)
resource "aws_eip" "nat" {
  count = length(var.private_subnet_cidrs) > 0 ? 1 : 0
  # vpc   = true
  tags = {
    Name = "${var.environment}-nat-eip"
  }
}

# NAT Gateway to enable outbound internet access for instances in private subnets.
# Note: Using a single NAT Gateway (in the first public subnet/AZ) for cost efficiency. In production, one NAT per AZ is recommended for high availability.
resource "aws_nat_gateway" "nat" {
  count         = length(var.private_subnet_cidrs) > 0 ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id
  tags = {
    Name = "${var.environment}-nat-gw"
  }
}

# Private route table for the VPC (routes private subnet traffic to the NAT Gateway for internet egress)
resource "aws_route_table" "private" {
  count  = length(var.private_subnet_cidrs) > 0 ? 1 : 0
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[0].id
  }
  tags = {
    Name = "${var.environment}-private-rt"
  }
}

# Associate each private subnet with the private route table (enable NAT routing for private subnets)
resource "aws_route_table_association" "private_association" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[0].id
}

# -------------------------------
# VPC Flow Logs for monitoring
# -------------------------------
resource "aws_flow_log" "vpc_flow_log" {
  iam_role_arn    = aws_iam_role.flow_log_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn
  traffic_type    = "REJECT"
  vpc_id          = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-vpc-flow-logs"
  }
}

# KMS key for CloudWatch logs encryption
resource "aws_kms_key" "cloudwatch_key" {
  description             = "KMS key for CloudWatch logs encryption - ${var.environment}"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name = "${var.environment}-cloudwatch-key"
  }
}

resource "aws_kms_alias" "cloudwatch_key_alias" {
  name          = "alias/${var.environment}-cloudwatch-key"
  target_key_id = aws_kms_key.cloudwatch_key.key_id
}

# CloudWatch Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/flowlogs-${var.environment}"
  retention_in_days = 30
  kms_key_id        = aws_kms_key.cloudwatch_key.arn

  tags = {
    Name = "${var.environment}-vpc-flow-logs"
  }
}

# IAM Role for VPC Flow Logs
resource "aws_iam_role" "flow_log_role" {
  name = "${var.environment}-flow-log-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.environment}-flow-log-role"
  }
}

# IAM Policy for VPC Flow Logs
resource "aws_iam_role_policy" "flow_log_policy" {
  name = "${var.environment}-flow-log-policy"
  role = aws_iam_role.flow_log_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect = "Allow"
        Resource = aws_cloudwatch_log_group.vpc_flow_logs.arn
      }
    ]
  })
}
