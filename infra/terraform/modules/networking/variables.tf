#############################
# File: infra/terraform/modules/networking/variables.tf
#############################

# Variables for the networking module.

variable "environment" {
  description = "Environment name (e.g., dev, prod) for tagging."
  type        = string
}

variable "vpc_cidr" {
  description = "IP address range (CIDR block) for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets. Should contain exactly two values for two subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}
