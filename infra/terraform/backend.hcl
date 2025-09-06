bucket         = "devops-apprenticeship-terraform-state"
key            = "env/dev/terraform.tfstate"
region         = "eu-north-1"          # match the bucket’s actual region
dynamodb_table = "terraform-state-lock" # must be in the same region
encrypt        = true
