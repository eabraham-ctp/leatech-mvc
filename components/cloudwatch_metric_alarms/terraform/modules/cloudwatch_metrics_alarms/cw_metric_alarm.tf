# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# CIS 3.x CloudWatch Metrics & Alarms

resource "aws_cloudwatch_log_metric_filter" "metric_filter" {
  name           = "${var.metric_name}"
  pattern        = "${var.metric_pattern}"
  log_group_name = "${var.cloudtrail_logs_group}"

  metric_transformation {
    name      = "${var.metric_transformation_name}"
    namespace = "${var.metric_transformation_namespace}"
    value     = "${var.metric_transformation_value}"
  }
}

resource "aws_cloudwatch_metric_alarm" "metric_alarm" {
  alarm_name                = "${var.alarm_name}"
  comparison_operator       = "${var.alarm_comparison_operator}"
  evaluation_periods        = "${var.alarm_evaluation_periods}"
  metric_name               = "${var.metric_transformation_name}"
  namespace                 = "${var.metric_transformation_namespace}"
  period                    = "${var.alarm_period}"
  statistic                 = "${var.alarm_statistic}"
  threshold                 = "${var.alarm_threshold}"
  alarm_description         = "${var.alarm_description}"
  treat_missing_data        = "${var.alarm_treat_missing_data}"
  insufficient_data_actions = ["${var.alarm_insufficient_action}"]
  alarm_actions             = ["${var.alert_topic}"]
  depends_on = ["aws_cloudwatch_log_metric_filter.metric_filter"]
}
