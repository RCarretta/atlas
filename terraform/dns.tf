# import the dns zone, which must already exist
data "aws_route53_zone" "eldritch-atlas-parent" {
  name         = var.parent_dns_zone
  private_zone = false
}

# for production / highest level domain, this needs to be created outside TF and imported
resource "aws_route53_zone" "eldritch-atlas" {
  name = var.dns_zone

  tags = {
    Environment = var.environment
  }
}

resource "aws_route53_record" "github-verified-domain" {
  count   = var.parent_dns_zone == var.dns_zone ? 1 : 0  # only create and manage this resource if this is not a subdomain
  name    = "_github-challenge-eldritch-atlas"
  type    = "TXT"
  ttl     = 300
  zone_id = data.aws_route53_zone.eldritch-atlas-parent.id
  records = ["fd1b134c84"]
}

# Add NS record to parent domain
resource "aws_route53_record" "zone-delegation" {
  count = var.dns_zone == var.parent_dns_zone ? 0 : 1  # only delegate if not top level
  name = trimsuffix(var.dns_zone, ".${var.parent_dns_zone}")
  type = "NS"
  ttl = 1440
  zone_id = data.aws_route53_zone.eldritch-atlas-parent.id
  records = aws_route53_zone.eldritch-atlas.name_servers
}

# Point DNS at the API Gateway - TODO this should be cloudfront
resource "aws_route53_record" "atlas-api" {
  name    = aws_api_gateway_domain_name.atlas.domain_name
  type    = "A"
  zone_id = aws_route53_zone.eldritch-atlas.id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.atlas.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.atlas.regional_zone_id
  }
}
