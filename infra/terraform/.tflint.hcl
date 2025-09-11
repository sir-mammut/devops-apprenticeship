config {
  call_module_type = false
}

plugin "aws" {
  enabled = true
  version = "0.30.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# aws_region = "us-east-1"

rule "aws_s3_bucket_versioning" { enabled = true }
rule "terraform_required_version" { enabled = true }
