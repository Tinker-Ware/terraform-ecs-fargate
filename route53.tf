data "aws_route53_zone" "selected" {
    name = var.domain
}

resource "aws_route53_record" "test" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "tftest.${var.domain}"
  type    = "A"

  alias {
    name                   = aws_alb.main.dns_name
    zone_id                = aws_alb.main.zone_id
    evaluate_target_health = true
  }
}