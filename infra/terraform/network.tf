# # Get 2 available AZs so the config is region-agnostic
# data "aws_availability_zones" "available" {
#   state = "available"
# }

# # VPC 10.0.0.0/16 with DNS
# resource "aws_vpc" "main" {
#   cidr_block           = "10.0.0.0/16"
#   enable_dns_support   = true
#   enable_dns_hostnames = true
#   tags                 = { Name = "devops-vpc" }
# }

# # Internet Gateway
# resource "aws_internet_gateway" "igw" {
#   vpc_id = aws_vpc.main.id
#   tags   = { Name = "devops-igw" }
# }

# # Public subnets (A & B) with auto public IPs
# resource "aws_subnet" "public_a" {
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = "10.0.1.0/24"
#   availability_zone       = data.aws_availability_zones.available.names[0]
#   map_public_ip_on_launch = true
#   tags                    = { Name = "public-a" }
# }

# resource "aws_subnet" "public_b" {
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = "10.0.2.0/24"
#   availability_zone       = data.aws_availability_zones.available.names[1]
#   map_public_ip_on_launch = true
#   tags                    = { Name = "public-b" }
# }

# # Public route table: 0.0.0.0/0 -> IGW
# resource "aws_route_table" "public" {
#   vpc_id = aws_vpc.main.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.igw.id
#   }
#   tags = { Name = "public-rt" }
# }

# # Associate subnets to public RT
# resource "aws_route_table_association" "pub_a" {
#   subnet_id      = aws_subnet.public_a.id
#   route_table_id = aws_route_table.public.id
# }
# resource "aws_route_table_association" "pub_b" {
#   subnet_id      = aws_subnet.public_b.id
#   route_table_id = aws_route_table.public.id
# }

# # Security group (ingress 3000/tcp, egress all) for future app
# resource "aws_security_group" "app_sg" {
#   name        = "app-sg-3000"
#   description = "Allow HTTP on 3000"
#   vpc_id      = aws_vpc.main.id

#   ingress {
#     description = "App port"
#     from_port   = 3000
#     to_port     = 3000
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"] # expose for demo; tighten later
#   }

#   egress {
#     description = "All egress"
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = { Name = "app-sg-3000" }
# }

# output "vpc_id" { value = aws_vpc.main.id }
# output "public_subnet_a" { value = aws_subnet.public_a.id }
# output "public_subnet_b" { value = aws_subnet.public_b.id }
# output "app_sg_id" { value = aws_security_group.app_sg.id }

# -------------------------------
# Core VPC
# -------------------------------
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

# -------------------------------
# Internet Gateway (public egress)
# -------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name_prefix}-igw"
  }
}

# -------------------------------
# Public subnets (one per AZ)
# -------------------------------
resource "aws_subnet" "public" {
  for_each = { for idx, cidr in var.public_subnet_cidrs : idx => {
    cidr = cidr
    az   = var.azs[idx]
  } }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = {
    Name = "${var.name_prefix}-public-${each.value.az}"
  }
}

# -------------------------------
# Public route table + default route to IGW
# -------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name_prefix}-public-rt"
  }
}

# Default route to the Internet
resource "aws_route" "public_inet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate every public subnet with the public route table
resource "aws_route_table_association" "public_assoc" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# -------------------------------
# Security group for app (ingress on app_port from anywhere)
# -------------------------------
resource "aws_security_group" "app_sg" {
  name        = "${var.name_prefix}-app-sg"
  description = "Allow app traffic on ${var.app_port}/tcp"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "App port"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    description = "HTTPS outbound to AWS services"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [
      "10.0.0.0/16",  # VPC internal
      "172.16.0.0/12", # Private networks
      "192.168.0.0/16" # Private networks
    ]
  }

  egress {
    description = "DNS outbound"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  tags = {
    Name = "${var.name_prefix}-app-sg"
  }
}

# -------------------------------
# VPC Flow Logs for monitoring
# -------------------------------
resource "aws_flow_log" "vpc_flow_log" {
  iam_role_arn    = aws_iam_role.flow_log_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn
  traffic_type    = "REJECT"
  vpc_id          = aws_vpc.this.id

  tags = {
    Name = "${var.name_prefix}-vpc-flow-logs"
  }
}

# KMS key for CloudWatch logs encryption
resource "aws_kms_key" "cloudwatch_key" {
  description             = "KMS key for CloudWatch logs encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name = "${var.name_prefix}-cloudwatch-key"
  }
}

resource "aws_kms_alias" "cloudwatch_key_alias" {
  name          = "alias/${var.name_prefix}-cloudwatch-key"
  target_key_id = aws_kms_key.cloudwatch_key.key_id
}

# CloudWatch Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/flowlogs"
  retention_in_days = 30
  kms_key_id        = aws_kms_key.cloudwatch_key.arn

  tags = {
    Name = "${var.name_prefix}-vpc-flow-logs"
  }
}

# IAM Role for VPC Flow Logs
resource "aws_iam_role" "flow_log_role" {
  name = "${var.name_prefix}-flow-log-role"

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
    Name = "${var.name_prefix}-flow-log-role"
  }
}

# IAM Policy for VPC Flow Logs
resource "aws_iam_role_policy" "flow_log_policy" {
  name = "${var.name_prefix}-flow-log-policy"
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
