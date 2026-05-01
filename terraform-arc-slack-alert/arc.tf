# 1. Create an ARC plan (Cluster, Control Panel, Routing Control)

resource "aws_route53recoverycontrolconfig_cluster" "main" {
  name = var.arc_cluster_name
}

resource "aws_route53recoverycontrolconfig_control_panel" "main" {
  name        = var.arc_control_panel_name
  cluster_arn = aws_route53recoverycontrolconfig_cluster.main.arn
}

resource "aws_route53recoverycontrolconfig_routing_control" "failover" {
  name              = var.arc_routing_control_name
  cluster_arn       = aws_route53recoverycontrolconfig_cluster.main.arn
  control_panel_arn = aws_route53recoverycontrolconfig_control_panel.main.arn
}

# Route53 Health check associated with the Routing Control
resource "aws_route53_health_check" "arc_failover" {
  type                = "ROUTING_CONTROL"
  routing_control_arn = aws_route53recoverycontrolconfig_routing_control.failover.arn

  tags = {
    Name = "${var.project_name}-arc-health-check"
  }
}
