resource "aws_appautoscaling_target" "autoscaling_target_webservice" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster_name}/${var.service_name_3}-service"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = 1
  max_capacity       = 2

  depends_on = [aws_ecs_service.webservice_service]
}

resource "aws_appautoscaling_policy" "webservice_up" {
  name               = "webservice_scale_up"
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster_name}/${var.service_name_3}-service"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 180
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = [aws_appautoscaling_target.autoscaling_target_webservice]
}

resource "aws_appautoscaling_policy" "webservice_down" {
  name               = "webservice_scale_down"
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster_name}/${var.service_name_3}-service"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 180
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [aws_appautoscaling_target.autoscaling_target_webservice]
}

# CPU
resource "aws_cloudwatch_metric_alarm" "webservice_cpu_high" {
  alarm_name          = "80-cpu-3min-avg-scaleout"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.webservice_service.name
  }

  alarm_actions = [aws_appautoscaling_policy.webservice_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "webservice_cpu_low" {
  alarm_name          = "40-cpu-3min-avg-scalein"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "180"
  statistic           = "Average"
  threshold           = "40"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.webservice_service.name
  }

  alarm_actions = [aws_appautoscaling_policy.webservice_down.arn]
}


# RAM
resource "aws_cloudwatch_metric_alarm" "webservice_ram_high" {
  alarm_name          = "80-ram-3min-avg-scaleout"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.webservice_service.name
  }

  alarm_actions = [aws_appautoscaling_policy.webservice_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "webservice_ram_low" {
  alarm_name          = "40-ram-3min-avg-scalein"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "180"
  statistic           = "Average"
  threshold           = "40"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.webservice_service.name
  }

  alarm_actions = [aws_appautoscaling_policy.webservice_down.arn]
}