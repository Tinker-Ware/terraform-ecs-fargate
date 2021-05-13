resource "aws_ecs_task_definition" "service_td" {
  family                   = "${var.service_name}-td"
  execution_role_arn       = var.execution_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_definition_cpu
  memory                   = var.task_definition_ram
  container_definitions    = jsonencode([
    {
      "name" = var.service_name,
      "image" = var.ecr_repo,
      "logConfiguration" = {
        "logDriver"=  "awslogs",
        "options" = {
          "awslogs-region" = var.aws_region,
          "awslogs-group" = aws_cloudwatch_log_group.service_log_group.name,
          "awslogs-stream-prefix" = aws_cloudwatch_log_stream.service_log_stream.name
        }
      },
      "portMappings" = [
        {
          "containerPort" = var.container_port,
          "hostPort" = var.host_port
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "ecs_service" {
  name            = "${var.service_name}-service"
  cluster         = var.aws_cluster_id
  task_definition = aws_ecs_task_definition.service_td.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [var.aws_security_group_id]
    # subnets         = aws_subnet.public.*.id
    subnets         = var.public_subnets
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app_tg.id
    container_name   = var.service_name
    container_port   = var.container_port
  }

  depends_on = [var.redirect_https_listener, var.https_listener]
}
