resource "aws_ecs_cluster" "main" {
  name = var.cluster_name
}

resource "aws_ecs_task_definition" "frontoffice_td" {
  family                   = "${var.service_name_1}-td"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  container_definitions    = jsonencode([
    {
      "name" = var.service_name_1,
      "image" = var.ecr_repo_1,
      "logConfiguration" = {
        "logDriver"=  "awslogs",
        "options" = {
          "awslogs-region" = var.aws_region,
          "awslogs-group" = aws_cloudwatch_log_group.webservice_log_group_1.name,
          "awslogs-stream-prefix" = aws_cloudwatch_log_stream.myapp_log_stream_1.name
        }
      },
      "portMappings" = [
        {
          "containerPort" = 80,
          "hostPort" = 80
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "frontoffice_service" {
  name            = "${var.service_name_1}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontoffice_td.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_sg.id]
    subnets         = [aws_subnet.public_1[0].id, aws_subnet.public_2[0].id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.frontoffice_tg.id
    container_name   = var.service_name_1
    container_port   = 80
  }

  depends_on = [aws_alb_listener.redirect_https, aws_alb_listener.hv_lb_https_listener, aws_iam_role_policy_attachment.ecs_task_execution_role]
}


# App 2
resource "aws_ecs_task_definition" "backoffice_td" {
  family                   = "${var.service_name_2}-td"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  container_definitions    = jsonencode([
    {
      "name" = var.service_name_2,
      "image" = var.ecr_repo_2,
      "logConfiguration" = {
        "logDriver"=  "awslogs",
        "options" = {
          "awslogs-region" = var.aws_region,
          "awslogs-group" = aws_cloudwatch_log_group.webservice_log_group_2.name,
          "awslogs-stream-prefix" = aws_cloudwatch_log_stream.myapp_log_stream_2.name
        }
      },
      "portMappings" = [
        {
          "containerPort" = 80,
          "hostPort" = 80
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "backoffice_service" {
  name            = "${var.service_name_2}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backoffice_td.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_sg.id]
    subnets         = [aws_subnet.public_1[0].id, aws_subnet.public_2[0].id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.backoffice_tg.id
    container_name   = var.service_name_2
    container_port   = 80
  }

  depends_on = [aws_alb_listener.redirect_https, aws_alb_listener.hv_lb_https_listener, aws_iam_role_policy_attachment.ecs_task_execution_role]
}


# App 3
resource "aws_ecs_task_definition" "webservice_td" {
  family                   = "${var.service_name_3}-td"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 2048
  container_definitions    = jsonencode([
    {
      "name" = var.service_name_3,
      "image" = var.ecr_repo_3,
      "logConfiguration" = {
        "logDriver"=  "awslogs",
        "options" = {
          "awslogs-region" = var.aws_region,
          "awslogs-group" = aws_cloudwatch_log_group.webservice_log_group_3.name,
          "awslogs-stream-prefix" = aws_cloudwatch_log_stream.myapp_log_stream_3.name
        }
      },
      "portMappings" = [
        {
          "containerPort" = 9095,
          "hostPort" = 9095
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "webservice_service" {
  name            = "${var.service_name_3}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.webservice_td.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_private_sg.id]
    subnets         = [aws_subnet.private_1.id,aws_subnet.private_2.id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.webservices-discovery.arn
  }

  depends_on = [aws_alb_listener.redirect_https, aws_alb_listener.hv_lb_https_listener, aws_iam_role_policy_attachment.ecs_task_execution_role]
}