data "aws_route53_zone" "selected" {
    name = var.domain
}

resource "aws_route53_record" "frontoffice_record" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.subdomain_1}.${var.domain}"
  type    = "A"

  alias {
    name                   = aws_alb.main.dns_name
    zone_id                = aws_alb.main.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "backoffice_record" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.subdomain_2}.${var.domain}"
  type    = "A"

  alias {
    name                   = aws_alb.main.dns_name
    zone_id                = aws_alb.main.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "webservice_record" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.subdomain_3}.${var.domain}"
  type    = "A"

  alias {
    name                   = aws_alb.main.dns_name
    zone_id                = aws_alb.main.zone_id
    evaluate_target_health = true
  }
}