##########################
# File: infra/terraform/envs/dev/variables.tf
##########################

# Input variables for the dev environment (with default values for convenience).

variable "aws_region" {
  description = "AWS region to deploy resources in."
  type        = string
  default     = "eu-north-1"
}

variable "aws_profile" {
  description = "AWS CLI profile name for credentials."
  type        = string
  default     = "devops-tf"
}

variable "environment" {
  description = "Environment name for tagging and naming resources."
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets."
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}
