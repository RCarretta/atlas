locals {
  cf_log_dir = "cf-logs"
  s3_origin_id = "s3"
  api_origin_id = "api"
}

# CF distribution for regional endpoint and optional caching
resource "aws_cloudfront_distribution" "frontend" {
  provider            = aws.us-east-1
  enabled             = true
  is_ipv6_enabled = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"
  aliases             = [var.dns_zone]

  logging_config {
    bucket          = var.logging_bucket_domain
    include_cookies = false
    prefix          = "${local.cf_log_dir}/"
  }

  origin {
    domain_name = var.api_domain_name
    origin_id = local.api_origin_id

    custom_origin_config {
      http_port = 80
      https_port             = "443"
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  origin {
    domain_name = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.frontend.cloudfront_access_identity_path
    }
  }

  ordered_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "PATCH", "POST", "DELETE"]
    cached_methods         = ["GET", "HEAD"]

    path_pattern           = "/api/*"
    target_origin_id       = local.api_origin_id
    viewer_protocol_policy = "redirect-to-https"
    default_ttl            = 0   # don't actually cache anything for now, unless explicitly set
    compress               = true

    # forward everything to the app. we can get fancy here, but for now let lambda handle it
    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
      headers = ["*"]
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"
    compress               = false
    default_ttl            = 0  # don't actually cache anything for now, unless explicitly set

    # forward nothing to S3
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  # in case an entire location needs to be blacklisted for some unknowable reason
  restrictions {
    geo_restriction {
      restriction_type = "none"
      #   locations        = []
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2019"
  }

  tags = {
    Environment = var.environment
  }
}

resource "aws_cloudfront_origin_access_identity" "frontend" {
  comment = "Frontend CF OAI - ${var.environment}"
}
