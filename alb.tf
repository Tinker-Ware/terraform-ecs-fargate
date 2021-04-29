data "aws_acm_certificate" "hv_cert" {
  domain    = var.domain
  statuses  = [ "ISSUED" ]
}

resource "aws_alb" "main" {
  name            = "healthyvita-lb"
  # subnets         = aws_subnet.public.*.id
  subnets         = [aws_subnet.public_1[0].id, aws_subnet.public_2[0].id]
  security_groups = [aws_security_group.lb.id]
}

resource "aws_alb_target_group" "webservice_tg" {
  name        = "webservice-tg"
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

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "ws_listener_rule" {
  load_balancer_arn = aws_alb.main.id
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = data.aws_acm_certificate.hv_cert.arn

  default_action {
    target_group_arn = aws_alb_target_group.webservice_tg.id
    type             = "forward"
  }
}