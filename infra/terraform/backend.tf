# backend.tf
terraform {
  backend "s3" {
    bucket         = "devops-apprenticeship-terraform-state"
    key            = "terraform.tfstate"
    region         = "eu-north-1" # Changed to match your bucket's actual region
    use_lockfile   = true
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    profile        = "devops-tf"
  }
}