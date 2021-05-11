resource "aws_cloudwatch_log_group" "service_log_group" {
  name              = "${var.service_name}_lg"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_stream" "service_log_stream" {
  name           = "${var.service_name}_ls"
  log_group_name = aws_cloudwatch_log_group.service_log_group.name
}
