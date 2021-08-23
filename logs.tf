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


resource "aws_cloudwatch_log_group" "api_authorizer_log_group" {
  name              = "api-authorizer_lg"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_stream" "api_authorizer_log_stream" {
  name           = "api-authorizer-logstream"
  log_group_name = aws_cloudwatch_log_group.api_authorizer_log_group.name
}

resource "aws_cloudwatch_log_group" "hv-api-lg" {
  name              = "/aws/lambda/hv-api-authorizer"
  retention_in_days = 14
}


