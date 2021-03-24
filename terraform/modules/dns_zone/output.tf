output "dns_zone_id" {
  value = var.dns_zone == var.parent_zone ? data.aws_route53_zone.parent_zone.id : aws_route53_zone.zone[0].id
}
