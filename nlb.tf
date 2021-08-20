resource "aws_lb" "private_nlb" {
  name               = "${var.cluster_name}-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = [aws_subnet.private_1.id,aws_subnet.private_2.id]
}

resource "aws_lb_target_group" "webservice_tg" {
  name        = "${var.service_name_3}-tg"
  port        = 80
  protocol    = "TCP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  
  depends_on = [
    aws_lb.private_nlb
  ]
}

# resource "aws_lb_target_group_attachment" "webservice_tg_attach" {
#   target_group_arn = aws_lb_target_group.webservice_tg.arn
#   target_id        = aws_ecs_service.webservice_service.id
# }

# resource "aws_lb_listener" "redirect_nlb_https" {
#   load_balancer_arn = aws_lb.private_nlb.arn
#   port              = "80"
#   protocol          = "TCP"

#   default_action {
#     type = "forward"
#     target_group_arn = aws_lb_target_group.webservice_tg.id
#   }
# }

resource "aws_alb_listener" "hv_nlb_https_listener" {
  load_balancer_arn = aws_lb.private_nlb.arn
  port              = 80
  protocol          = "TCP"
  #certificate_arn   = data.aws_acm_certificate.hv_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webservice_tg.id
  }
}