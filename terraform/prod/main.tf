module "dns_zone" {
  source      = "../modules/dns_zone"
  dns_zone    = var.dns_zone
  parent_zone = var.dns_zone
  environment = var.environment
}

module "certificate" {
  source      = "../modules/certificate"
  environment = var.environment
  dns_zone    = var.dns_zone
  dns_zone_id = module.dns_zone.dns_zone_id

}
module "dynamodb" {
  source      = "../modules/dynamodb"
  environment = var.environment
}

module "api" {
  source          = "../modules/api"
  environment     = var.environment
  dns_zone        = var.dns_zone
  certificate_arn = module.certificate.certificate_arn
}

module "logging" {
  source = "../modules/logging"
  application_name = var.application_name
  environment = var.environment
}

module "frontend" {
  source = "../modules/frontend"
  api_domain_name = module.api.api_domain_name
  application_name = var.application_name
  environment = var.environment
  certificate_arn = module.certificate.certificate_arn
  dns_zone = var.dns_zone
  logging_bucket_domain = module.logging.logging_bucket_domain
}

resource "aws_route53_record" "github-verified-domain" {
  count   = var.parent_zone == var.dns_zone ? 1 : 0 # only create and manage this resource if this is not a subdomain
  name    = "_github-challenge-eldritch-atlas"
  type    = "TXT"
  ttl     = 300
  zone_id = module.dns_zone.dns_zone_id
  records = ["fd1b134c84"]
}

resource "aws_sns_topic" "alerts" {
  name = "${var.environment}-alerts"
  tags = {
    Environment = var.environment
  }
}

resource "aws_s3_bucket" "pipeline" {
  bucket = "${var.environment}-${var.application_name}-pipeline"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

module "api_lambda_document" {
  source = "../modules/lambda_api_handler"
  application_name = var.application_name
  environment = var.environment
  lambda_dead_letter_arn = aws_sns_topic.alerts.arn
  lambda_desc = "API for /document and subtree"
  lambda_name = "document"
  lambda_runtime = "python3.6"
}

module "frontend_pipeline" {
  source = "../modules/cicd_pipeline_frontend"
  application_name = var.application_name
  artifact_bucket = aws_s3_bucket.pipeline.bucket
  environment = var.environment
  monitored_branch = var.pipeline_branch['frontend']
  repository = var.repositories['frontend']
  web_bucket = var.dns_zone
}
