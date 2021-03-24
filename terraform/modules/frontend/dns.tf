data "aws_route53_zone" "dns_zone" {
  name = var.dns_zone
  private_zone = false
}

resource "aws_route53_record" "frontend" {
  name = var.dns_zone
  type = "A"
  zone_id = data.aws_route53_zone.dns_zone.id

  alias {
    evaluate_target_health = false
    name = aws_cloudfront_distribution.frontend.domain_name
    zone_id = aws_cloudfront_distribution.frontend.hosted_zone_id
  }
}
