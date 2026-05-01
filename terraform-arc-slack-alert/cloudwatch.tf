# 2. Create a cloudwatch event that listens to arc failover
resource "aws_cloudwatch_event_rule" "arc_failover_event" {
  name        = "${var.project_name}-arc-event"
  description = "Capture ARC routing control state changes"

  event_pattern = jsonencode({
    source = ["aws.route53-recovery-control"]
    "detail-type" = ["Route53 Recovery Control Routing Control State Change"]
    detail = {
      RoutingControlArn = [aws_route53recoverycontrolconfig_routing_control.failover.arn]
    }
  })
}

# Target for EventBridge Rule to trigger Lambda (Satisfies listening to ARC failover directly)
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.arc_failover_event.name
  target_id = "SendToSlack"
  arn       = aws_lambda_function.slack_notifier.arn
}

# 4. ARC failover event should trigger cloudwatch alarm
resource "aws_cloudwatch_metric_alarm" "arc_failover_alarm" {
  alarm_name          = "${var.project_name}-failover-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = 60
  statistic           = "Minimum"
  threshold           = 1
  alarm_description   = "This alarm monitors the Route53 Health Check for ARC routing control failover."

  dimensions = {
    HealthCheckId = aws_route53_health_check.arc_failover.id
  }

  # 5. Cloud watch alarm should trigger lambda function (via SNS to follow AWS best practices)
  alarm_actions = [aws_sns_topic.arc_alerts.arn]
  ok_actions    = [aws_sns_topic.arc_alerts.arn]
}

# SNS Topic to route CloudWatch Alarms to Lambda
resource "aws_sns_topic" "arc_alerts" {
  name = "${var.project_name}-alerts"
}

# SNS Subscription for Lambda
resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = aws_sns_topic.arc_alerts.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.slack_notifier.arn
}
