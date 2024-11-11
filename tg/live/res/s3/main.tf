#tfsec:ignore:aws-s3-enable-bucket-logging
module "bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  tags = {
    Managed_by = "Terragrunt"
  }

  bucket = local.bucket_name

  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  versioning = {
    enabled    = false
    mfa_delete = false
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
}
