#######################
# File: infra/terraform/envs/dev/backend.tf
#######################

# Remote backend configuration: use S3 for state storage and DynamoDB for state locking.

terraform {
  backend "s3" {
    bucket         = "devops-apprenticeship-terraform-state"
    key            = "envs/dev/terraform.tfstate" # path within the bucket for this env's state file
    region         = "eu-north-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    profile        = "devops-tf"
    use_lockfile   = true
  }
}
