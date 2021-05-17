resource "aws_cloudwatch_log_group" "webservice_log_group_1" {
  name              = "${var.service_name_1}_lg"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_stream" "myapp_log_stream_1" {
  name           = "${var.service_name_1}-logstream"
  log_group_name = aws_cloudwatch_log_group.webservice_log_group_1.name
}


resource "aws_cloudwatch_log_group" "webservice_log_group_2" {
  name              = "${var.service_name_2}_lg"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_stream" "myapp_log_stream_2" {
  name           = "${var.service_name_2}-logstream"
  log_group_name = aws_cloudwatch_log_group.webservice_log_group_2.name
}


resource "aws_cloudwatch_log_group" "webservice_log_group_3" {
  name              = "${var.service_name_3}_lg"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_stream" "myapp_log_stream_3" {
  name           = "${var.service_name_3}-logstream"
  log_group_name = aws_cloudwatch_log_group.webservice_log_group_3.name
}