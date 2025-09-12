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

# KMS key for S3 encryption
resource "aws_kms_key" "s3_key" {
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name = "tf-state-s3-key"
  }
}

resource "aws_kms_alias" "s3_key_alias" {
  name          = "alias/tf-state-s3-key"
  target_key_id = aws_kms_key.s3_key.key_id
}

# KMS key for DynamoDB encryption
resource "aws_kms_key" "dynamodb_key" {
  description             = "KMS key for DynamoDB table encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name = "tf-state-dynamodb-key"
  }
}

resource "aws_kms_alias" "dynamodb_key_alias" {
  name          = "alias/tf-state-dynamodb-key"
  target_key_id = aws_kms_key.dynamodb_key.key_id
}

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

# Enable S3 bucket logging
resource "aws_s3_bucket_logging" "tf_state_logging" {
  bucket = aws_s3_bucket.tf_state.id

  target_bucket = aws_s3_bucket.tf_state.id
  target_prefix = "access-logs/"
}

# Server-side encryption (SSE-KMS with customer managed key)
resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state_sse" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_key.arn
    }
    bucket_key_enabled = true
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

  # Enable encryption at rest with customer-managed KMS key
  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.dynamodb_key.arn
  }

  # Enable point-in-time recovery
  point_in_time_recovery {
    enabled = true
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