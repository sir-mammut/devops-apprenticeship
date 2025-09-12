provider "aws" {
  # region  = var.aws_region
  profile = var.aws_profile
  region  = var.region
  default_tags {
    tags = {
      Project     = "devops-apprenticeship"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
