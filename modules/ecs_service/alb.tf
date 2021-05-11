resource "aws_alb_target_group" "app_tg" {
  name        = "${var.service_name}-tg"
  port        = var.target_group_port
  protocol    = var.target_group_protocol
  vpc_id      = var.vpc_id
  target_type = var.target_type

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

resource "aws_lb_listener_rule" "redirect_routing_rule" {
  count         = 1 ? var.create_redirect_rule : 0
  listener_arn  = var.alb_listener_arn
  priority      = var.rule_priority

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
      values = ["${var.subdomain}.${var.domain}"]
    }
  }

  depends_on = [ var.https_listener ]
}

resource "aws_lb_listener_rule" "forward_routing_rule" {
  count         = 1 ? var.create_forward_rule : 0
  listener_arn = var.alb_listener_arn
  priority     = var.rule_priority

  action {
    type             = "forward"
    target_group_arn = var.target_group_arn
  }

  condition {
    host_header {
      values = ["${var.subdomain}.${var.domain}"]
    }
  }

  depends_on = [ var.https_listener ]
}