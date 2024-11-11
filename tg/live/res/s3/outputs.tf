output "bucket" {
  value = {
    bucket_id   = module.bucket.s3_bucket_id
    domain_name = module.bucket.s3_bucket_bucket_regional_domain_name
  }
}
