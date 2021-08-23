resource "aws_lb" "private-nlb" {
  name               = "${var.cluster_name}-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = [aws_subnet.private_1.id,aws_subnet.private_2.id]
}

resource "aws_lb_target_group" "webservice-tg" {
  name        = "${var.service_name_3}-tg"
  port        = 80
  protocol    = "TCP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  
  depends_on = [
    aws_lb.private-nlb
  ]
}

resource "aws_alb_listener" "hv-nlb-ws-listener" {
  load_balancer_arn = aws_lb.private-nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webservice-tg.id
  }
}