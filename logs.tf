# logs.tf

# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "webservice_log_group" {
  name              = var.service_name
  retention_in_days = 7
}

resource "aws_cloudwatch_log_stream" "myapp_log_stream" {
  name           = "task-log"
  log_group_name = aws_cloudwatch_log_group.webservice_log_group.name
}