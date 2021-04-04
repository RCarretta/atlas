resource "aws_s3_bucket" "logging" {
  bucket = "${var.environment}-${var.application_name}-logging"
  acl    = "log-delivery-write"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    enabled = true
    expiration {
      days = 14
    }
  }

  tags = {
    Environment = var.environment
  }
}
