resource "aws_ecs_cluster" "main" {
  name = var.cluster_name
}

resource "aws_ecs_task_definition" "webservice_td" {
  family                   = "${var.service_name}-td"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 2048
  container_definitions    = jsonencode([
    {
      "name" = var.service_name,
      "image" = var.ecr_repo,
      "cpu" = 0,
      "memory" = 128,
      "logConfiguration" = {
        "logDriver"=  "awslogs",
        "options" = {
          "awslogs-region" = var.aws_region,
          "awslogs-group" = aws_cloudwatch_log_group.webservice_log_group.name,
          "awslogs-stream-prefix" = "hv-ecs"
        }
      },
      "portMappings" = [
        {
          "containerPort" = 80,
          "hostPort" = 80
        }
        # {
        #   "containerPort": 465,
        #   "hostPort": 465
        # }
      ]
    }
  ])
}

resource "aws_ecs_service" "webservice_service" {
  name            = "${var.service_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.webservice_td.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_sg.id]
    # subnets         = aws_subnet.public.*.id
    subnets         = [aws_subnet.public_1[0].id, aws_subnet.public_2[0].id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.webservice_tg.id
    container_name   = var.service_name
    container_port   = 80
  }

  depends_on = [aws_alb_listener.redirect_https, aws_alb_listener.ws_listener_rule, aws_iam_role_policy_attachment.ecs_task_execution_role]
}