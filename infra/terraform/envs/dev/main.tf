#######################
# File: infra/terraform/envs/dev/main.tf
#######################

# Terraform configuration for the "dev" environment. 
# This sets up the AWS provider (using region and profile) and calls the networking module.

terraform {
  required_version = ">= 1.6.0, < 2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.65"
    }
  }
}

# AWS provider configuration for the dev environment
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
  # Apply common tags to all resources (for consistency and easy identification)
  default_tags {
    tags = {
      Project     = "devops-apprenticeship"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# Use the networking module to provision VPC and networking components for this environment.
module "networking" {
  source              = "../../modules/networking"
  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
}
