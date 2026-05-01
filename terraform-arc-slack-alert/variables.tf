variable "aws_region" {
  description = "AWS Region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for tagging and naming resources"
  type        = string
  default     = "arc-slack-alert"
}

variable "slack_webhook_url" {
  description = "Slack webhook URL for sending alerts"
  type        = string
  sensitive   = true
}

variable "arc_cluster_name" {
  description = "Name for the ARC Cluster"
  type        = string
  default     = "main-cluster"
}

variable "arc_control_panel_name" {
  description = "Name for the ARC Control Panel"
  type        = string
  default     = "main-control-panel"
}

variable "arc_routing_control_name" {
  description = "Name for the ARC Routing Control"
  type        = string
  default     = "failover-routing-control"
}
