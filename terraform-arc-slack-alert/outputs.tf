output "arc_cluster_arn" {
  value = aws_route53recoverycontrolconfig_cluster.main.arn
  description = "ARN of the ARC Cluster"
}

output "arc_control_panel_arn" {
  value = aws_route53recoverycontrolconfig_control_panel.main.arn
  description = "ARN of the ARC Control Panel"
}

output "arc_routing_control_arn" {
  value = aws_route53recoverycontrolconfig_routing_control.failover.arn
  description = "ARN of the ARC Routing Control"
}

output "cloudwatch_alarm_arn" {
  value = aws_cloudwatch_metric_alarm.arc_failover_alarm.arn
  description = "ARN of the CloudWatch Alarm monitoring the failover"
}

output "lambda_function_arn" {
  value = aws_lambda_function.slack_notifier.arn
  description = "ARN of the Slack Notifier Lambda Function"
}

output "sns_topic_arn" {
  value = aws_sns_topic.arc_alerts.arn
  description = "ARN of the SNS Topic for Alerts"
}
