# Website Bucket
resource "aws_s3_bucket" "website" {
  #  bucket = substr(var.dns_zone, 0, length(var.dns_zone) - 1)
  bucket = var.dns_zone
  acl    = "private"  # bucket policy via the aws_s3_bucket_policy resource

  # don't pay for versioning - handled via code checkins
  versioning {
    enabled = false
  }

  lifecycle_rule {
    id      = "multipart"
    enabled = true

    noncurrent_version_expiration {
      days = 3
    }

    # dont spend money on lingering/stale uploads
    abort_incomplete_multipart_upload_days = 1
  }

  website {
    index_document = "index.html"
  }

  # no cors_rule necessary, as this will be pulled by cloudfront exclusively

  tags = {
    Environment = var.environment
  }
}

resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.bucket
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Id": "PolicyForCloudFrontPrivateContent",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_cloudfront_origin_access_identity.frontend.iam_arn}"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.website.bucket}/*"
        }
    ]
}
EOF
}
