########################
# File: infra/terraform/envs/dev/outputs.tf
########################

# Expose key infrastructure IDs for visibility and potential use by other components.

output "vpc_id" {
  description = "ID of the VPC deployed in the dev environment."
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets in the dev VPC."
  value       = module.networking.public_subnet_ids
}

output "public_route_table_id" {
  description = "ID of the public route table associated with the dev VPC."
  value       = module.networking.public_route_table_id
}

output "igw_id" {
  description = "ID of the Internet Gateway for the dev VPC."
  value       = module.networking.igw_id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets in the dev VPC."
  value       = module.networking.private_subnet_ids
}

output "private_route_table_id" {
  description = "ID of the private route table for the dev VPC (for private subnets)."
  value       = module.networking.private_route_table_id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway providing internet egress for private subnets."
  value       = module.networking.nat_gateway_id
}

output "nat_gateway_eip" {
  description = "Public Elastic IP address of the NAT Gateway."
  value       = module.networking.nat_gateway_eip
}
