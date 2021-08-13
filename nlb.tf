resource "aws_lb" "private_nlb" {
  name               = "${var.cluster_name}-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = [aws_subnet.private_1.id,aws_subnet.private_2.id]
}

resource "aws_lb_target_group" "webservice_tg" {
  name        = "${var.service_name_3}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  
}

resource "aws_lb_target_group_attachment" "webservice_tg_attach" {
  target_group_arn = aws_lb_target_group.webservice_tg.arn
  target_id        = aws_service_discovery_service.webservices-discovery.id
  port             = 80
}

resource "aws_lb_listener" "redirect_nlb_https" {
  load_balancer_arn = aws_lb.private_nlb.arn
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

resource "aws_alb_listener" "hv_nlb_https_listener" {
  load_balancer_arn = aws_lb.private_nlb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = data.aws_acm_certificate.hv_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webservice_tg.id
  }
}