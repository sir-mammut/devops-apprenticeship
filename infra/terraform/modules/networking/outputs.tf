##########################
# File: infra/terraform/modules/networking/outputs.tf
##########################

# Output values from the networking module (to be used by environment configurations).

output "vpc_id" {
  description = "The ID of the created VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets created in the VPC."
  value       = aws_subnet.public[*].id
}

output "public_route_table_id" {
  description = "The ID of the public route table for the VPC."
  value       = aws_route_table.public.id
}

output "igw_id" {
  description = "The ID of the Internet Gateway for the VPC."
  value       = aws_internet_gateway.gw.id
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets created in the VPC (if any)."
  value       = aws_subnet.private[*].id
}

output "private_route_table_id" {
  description = "The ID of the private route table (for private subnets, if created)."
  value       = length(aws_route_table.private) > 0 ? aws_route_table.private[0].id : null
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway (if private subnets are configured)."
  value       = length(aws_nat_gateway.nat) > 0 ? aws_nat_gateway.nat[0].id : null
}

output "nat_gateway_eip" {
  description = "The Elastic IP address allocated to the NAT Gateway (if any)."
  value       = length(aws_eip.nat) > 0 ? aws_eip.nat[0].public_ip : null
}
