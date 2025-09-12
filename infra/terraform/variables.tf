variable "region" {
  type        = string
  description = "AWS region to deploy into"
  default     = "eu-north-1"
}

variable "aws_profile" {
  description = "AWS CLI profile."
  type        = string
  default     = "devops-tf"
}

variable "environment" {
  description = "Env tag."
  type        = string
  default     = "dev"
}

variable "name_prefix" {
  type        = string
  description = "Name prefix used for resource tags/names"
  default     = "devops-apprentice"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDRs for public subnets (one per AZ)"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "azs" {
  type        = list(string)
  description = "AZs for the public subnets (must match list length)"
  # For eu-north-1 only has a/b/c — pick two you like
  default = ["eu-north-1a", "eu-north-1b"]
}

variable "app_port" {
  type        = number
  description = "Ingress port to open on the app security group"
  default     = 3000
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks allowed to access the application"
  default     = ["10.0.0.0/16"] # Restrict to VPC by default
}

variable "map_public_ip_on_launch" {
  type        = bool
  description = "Whether to automatically assign public IPs to instances launched in public subnets"
  default     = false # Disable by default for security
}