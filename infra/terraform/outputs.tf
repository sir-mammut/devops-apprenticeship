output "vpc_id" {
  value       = aws_vpc.this.id
  description = "VPC ID"
}

output "public_subnet_ids" {
  value       = [for s in aws_subnet.public : s.id]
  description = "IDs of public subnets"
}

output "public_route_table_id" {
  value       = aws_route_table.public.id
  description = "Public route table ID"
}

output "internet_gateway_id" {
  value       = aws_internet_gateway.igw.id
  description = "IGW ID"
}

output "app_sg_id" {
  value       = aws_security_group.app_sg.id
  description = "App security group ID"
}
