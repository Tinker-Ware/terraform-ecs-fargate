output "service_target_group" {
    value = aws_alb_target_group.app_tg.id
}