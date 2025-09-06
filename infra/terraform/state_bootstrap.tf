# # S3 bucket for remote state (versioned, private, encrypted)
# resource "aws_s3_bucket" "tf_state" {
#   bucket        = "devops-apprenticeship-terraform-state"   # e.g., sir-mammut-tf-state-20250830
#   force_destroy = true                # allows terraform destroy even if objects exist (lab only)

#   tags = { Name = "tf-state-bucket" }
# }

# # Block all public access
# resource "aws_s3_bucket_public_access_block" "tf_state_block" {
#   bucket                  = aws_s3_bucket.tf_state.id
#   block_public_acls       = true
#   block_public_policy     = true
#   restrict_public_buckets = true
#   ignore_public_acls      = true
# }

# # Enable versioning
# resource "aws_s3_bucket_versioning" "tf_state_versioning" {
#   bucket = aws_s3_bucket.tf_state.id
#   versioning_configuration { status = "Enabled" }
# }

# # Server-side encryption (SSE-S3)
# resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state_sse" {
#   bucket = aws_s3_bucket.tf_state.id
#   rule {
#     apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
#   }
# }

# # DynamoDB lock table (prevents concurrent state changes)
# resource "aws_dynamodb_table" "tf_lock" {
#   name         = "terraform-state-lock"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "LockID"

#   attribute { name = "LockID"; type = "S" }

#   tags = { Name = "tf-state-lock" }
# }

# output "state_bucket" { value = aws_s3_bucket.tf_state.bucket }
# output "lock_table"   { value = aws_dynamodb_table.tf_lock.name }

# S3 bucket for remote state (versioned, private, encrypted)
resource "aws_s3_bucket" "tf_state" {
  bucket        = "devops-apprenticeship-terraform-state"
  force_destroy = true # allows terraform destroy even if objects exist (lab only)
  tags = {
    Name = "tf-state-bucket"
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "tf_state_block" {
  bucket                  = aws_s3_bucket.tf_state.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

# Enable versioning
resource "aws_s3_bucket_versioning" "tf_state_versioning" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Server-side encryption (SSE-S3)
resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state_sse" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# DynamoDB lock table (prevents concurrent state changes)
resource "aws_dynamodb_table" "tf_lock" {
  name         = "terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "tf-state-lock"
  }
}

output "state_bucket" {
  value = aws_s3_bucket.tf_state.bucket
}

output "lock_table" {
  value = aws_dynamodb_table.tf_lock.name
}