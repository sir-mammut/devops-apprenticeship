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
  description = "List of CIDR blocks for public subnets (one per AZ, e.g., two for 2 AZs)."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets. If provided, a NAT Gateway is created for egress. Defaults to empty (no private subnets)."
  type        = list(string)
  default     = []
}

variable "map_public_ip_on_launch" {
  description = "Whether to automatically assign public IPs to instances launched in public subnets. Set to false for security."
  type        = bool
  default     = false
}
