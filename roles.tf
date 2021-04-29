# # ECS task execution role data
# data "aws_iam_policy_document" "ecs_task_execution_role" {
#   version = "2012-10-17"
#   statement {
#     sid = ""
#     effect = "Allow"
#     actions = ["sts:AssumeRole"]

#     principals {
#       type        = "Service"
#       identifiers = ["ecs-tasks.amazonaws.com"]
#     }
#   }
# }

# # ECS task execution role
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecs-task-execution-role"
  assume_role_policy = jsonencode(
  # {
  #   "Version" = "2012-10-17",
  #   "Statement" = [
  #     {
  #       "Effect" = "Allow",
  #       "Action" = [
  #           "ecr:GetAuthorizationToken",
  #           "ecr:BatchCheckLayerAvailability",
  #           "ecr:GetDownloadUrlForLayer",
  #           "ecr:BatchGetImage",
  #           "logs:CreateLogStream",
  #           "logs:PutLogEvents"
  #       ],
  #       "Resource" = "*"
  #     }
  #   ]
  # }
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "",
        "Effect": "Allow",
        "Principal": {
          "Service": [
            "ecs-tasks.amazonaws.com"
          ]
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  )
}


# ECS task execution role policy attachment
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}