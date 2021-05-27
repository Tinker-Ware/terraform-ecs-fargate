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


#service discovery for private services
resource "aws_service_discovery_private_dns_namespace" "private-dns" {
  name = "${var.domain}"
  vpc = aws_vpc.main.id
}

resource "aws_service_discovery_service" "webservices-discovery" {
  name = "${var.subdomain_3}"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.private-dns.id
    routing_policy = "MULTIVALUE"

    dns_records {
      ttl = 60
      type = "A"
      
    }
  }
  health_check_custom_config {
    failure_threshold = 5
  }
}