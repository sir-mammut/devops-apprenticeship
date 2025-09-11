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
