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
