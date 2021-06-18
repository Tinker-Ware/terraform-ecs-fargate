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

#app mesh virtual node
resource "aws_appmesh_mesh" "private_subnet_mesh" {
  name = "private_subnet_mesh"
}

# resource "aws_service_discovery_http_namespace" "webservice_endpoint" {
#   name = "${var.domain}"
# }

resource "aws_appmesh_virtual_service" "webservice_vs" {
  name      = "api-stage-vs"
  mesh_name = aws_appmesh_mesh.private_subnet_mesh.id

  spec {
    provider {
      virtual_node {
        virtual_node_name = aws_appmesh_virtual_node.webservice-vn.name
      }
    }
  }
}

resource "aws_appmesh_virtual_node" "webservice-vn" {
  name      = "${var.service_name_3}"
  mesh_name = aws_appmesh_mesh.private_subnet_mesh.id

  spec {
    backend {
      virtual_service {
        virtual_service_name = "api-stage-vs"
        client_policy {
          tls {
            validation{
              trust {
                acm {
                  certificate_authority_arns = [data.aws_acm_certificate.hv_cert.arn]
                }
              }
            }
          }
        }
      }
    }

    listener {
      port_mapping {
        port     = 9095
        protocol = "http"
      }
    }

    service_discovery {
      dns {
          hostname = "${var.subdomain_3}.${var.domain}"
        }  
    }
  }
}