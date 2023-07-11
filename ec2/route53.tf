data "aws_acm_certificate" "acm" {
  domain = var.project_domain
}

resource "aws_route53_record" "name" {
  for_each = toset([for subdomain in var.subdomains: "${subdomain}.${var.project_domain}"])
  zone_id = data.aws_route53_zone.hostedZone.zone_id
  name = each.key
  type = "A"
  alias {
    evaluate_target_health = true
    name = aws_lb.loadbalancer.dns_name
    zone_id = aws_lb.loadbalancer.zone_id
  }
}

data "aws_route53_zone" "hostedZone" {
  name = var.project_domain
  private_zone = false
}