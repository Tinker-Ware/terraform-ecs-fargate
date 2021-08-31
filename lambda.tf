resource "aws_lambda_function" "authorizer" {
  filename      = "hv-apigw-python-authorizer.zip"
  function_name = "hv-api-authorizer-stage"
  role          = aws_iam_role.lambda.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"

  source_code_hash = filebase64sha256("hv-apigw-python-authorizer.zip")

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.hv-api-lg,
  ]
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}
