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
  count   = var.parent_dns_zone == var.dns_zone ? 1 : 0 # only create and manage this resource if this is not a subdomain
  name    = "_github-challenge-eldritch-atlas"
  type    = "TXT"
  ttl = 300
  zone_id = data.aws_route53_zone.eldritch-atlas-parent.id
  records = ["fd1b134c84"]
}
