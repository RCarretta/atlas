# import the dns zone, which must already exist
data "aws_route53_zone" "parent_zone" {
  name         = var.parent_zone
  private_zone = false
}

# for production / highest level domain, this needs to be created outside TF and imported
resource "aws_route53_zone" "zone" {
  name = var.dns_zone

  tags = {
    Environment = var.environment
  }
}

# Add NS record to parent domain
resource "aws_route53_record" "zone-delegation" {
  count = var.dns_zone == var.parent_zone ? 0 : 1  # only delegate if not top level
  name = trimsuffix(var.dns_zone, ".${var.parent_zone}")
  type = "NS"
  ttl = 1440
  zone_id = data.aws_route53_zone.parent_zone.id
  records = aws_route53_zone.zone.name_servers
}
