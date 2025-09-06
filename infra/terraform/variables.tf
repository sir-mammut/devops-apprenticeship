variable "aws_region" {
  description = "AWS region."
  type        = string
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

