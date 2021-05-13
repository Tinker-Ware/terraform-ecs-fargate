resource "aws_appautoscaling_target" "autoscaling_target_service" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster_name}/${var.service_name}-service"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = 1
  max_capacity       = 2

  depends_on = [aws_ecs_service.ecs_service]
}

resource "aws_appautoscaling_policy" "service_up" {
  name               = "service-scale-up"
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster_name}/${var.service_name}-service"
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

  depends_on = [aws_appautoscaling_target.autoscaling_target_service]
}

resource "aws_appautoscaling_policy" "service_down" {
  name               = "service_scale_down"
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster_name}/${var.service_name}-service"
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

  depends_on = [aws_appautoscaling_target.autoscaling_target_service]
}

# CPU
resource "aws_cloudwatch_metric_alarm" "service_cpu_high" {
  alarm_name          = "80-cpu-3min-avg-scaleout"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    ClusterName = var.aws_cluster_name
    ServiceName = aws_ecs_service.ecs_service.name
  }

  alarm_actions = [aws_appautoscaling_policy.service_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "service_cpu_low" {
  alarm_name          = "40-cpu-3min-avg-scalein"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "180"
  statistic           = "Average"
  threshold           = "40"

  dimensions = {
    ClusterName = var.aws_cluster_name
    ServiceName = aws_ecs_service.ecs_service.name
  }

  alarm_actions = [aws_appautoscaling_policy.service_down.arn]
}


# RAM
resource "aws_cloudwatch_metric_alarm" "backoffice_ram_high" {
  alarm_name          = "80-ram-3min-avg-scaleout"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    ClusterName = var.aws_cluster_name
    ServiceName = aws_ecs_service.ecs_service.name
  }

  alarm_actions = [aws_appautoscaling_policy.service_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "service_ram_low" {
  alarm_name          = "40-ram-3min-avg-scalein"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "180"
  statistic           = "Average"
  threshold           = "40"

  dimensions = {
    ClusterName = var.aws_cluster_name
    ServiceName = aws_ecs_service.ecs_service.name
  }

  alarm_actions = [aws_appautoscaling_policy.service_down.arn]
}