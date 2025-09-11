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
  map_public_ip_on_launch = true

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
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-app-sg"
  }
}
