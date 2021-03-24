output "logging_bucket" {
  value = aws_s3_bucket.logging.bucket
}

output "logging_bucket_domain" {
  value = aws_s3_bucket.logging.bucket_domain_name
}
