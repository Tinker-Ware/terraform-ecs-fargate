data "aws_acm_certificate" "hv_cert" {
  domain    = var.domain
  statuses  = [ "ISSUED" ]
}

resource "aws_alb" "main" {
  name            = "${var.cluster_name}-lb"
  subnets         = [aws_subnet.public_1[0].id, aws_subnet.public_2[0].id]
  security_groups = [aws_security_group.lb.id]
}

resource "aws_alb_target_group" "frontoffice_tg" {
  name        = "${var.service_name_1}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "5"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "5"
    path                = "/"
    unhealthy_threshold = "2"
  }
}

# App 2
resource "aws_alb_target_group" "backoffice_tg" {
  name        = "${var.service_name_2}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "5"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "5"
    path                = "/"
    unhealthy_threshold = "2"
  }
}

# App 3
resource "aws_alb_target_group" "webservice_tg" {
  name        = "${var.service_name_3}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "5"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "5"
    path                = "/"
    unhealthy_threshold = "2"
  }
}


resource "aws_alb_listener" "redirect_https" {
  load_balancer_arn = aws_alb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Redirect all traffic from the ALB to the target groups
resource "aws_alb_listener" "hv_lb_https_listener" {
  load_balancer_arn = aws_alb.main.id
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = data.aws_acm_certificate.hv_cert.arn

  default_action {
    target_group_arn = aws_alb_target_group.frontoffice_tg.id
    type             = "forward"
  }
}


resource "aws_lb_listener_rule" "frontoffice_routing_rule" {
  listener_arn = aws_alb_listener.hv_lb_https_listener.arn
  priority     = 1

  action {
    type = "redirect"

    redirect {
      host        = var.domain
      path        = "/"
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = ["${var.subdomain_1}.${var.domain}"]
    }
  }

  depends_on = [aws_alb_listener.hv_lb_https_listener]
}

resource "aws_lb_listener_rule" "backoffice_routing_rule" {
  listener_arn = aws_alb_listener.hv_lb_https_listener.arn
  priority     = 2

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.backoffice_tg.arn
  }

  condition {
    host_header {
      values = ["${var.subdomain_2}.${var.domain}"]
    }
  }

  depends_on = [aws_alb_listener.hv_lb_https_listener]
}

resource "aws_lb_listener_rule" "webservice_routing_rule" {
  listener_arn = aws_alb_listener.hv_lb_https_listener.arn
  priority     = 3

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.webservice_tg.arn
  }

  condition {
    host_header {
      values = ["${var.subdomain_3}.${var.domain}"]
    }
  }

  depends_on = [aws_alb_listener.hv_lb_https_listener]
}