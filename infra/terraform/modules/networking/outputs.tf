##########################
# File: infra/terraform/modules/networking/outputs.tf
##########################

# Output values from the networking module (to be used by root modules/environments).

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
