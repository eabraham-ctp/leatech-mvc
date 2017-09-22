# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# CIS 3.x CloudWatch Metrics & Alarms

output "filter_id" {
	value = "${aws_cloudwatch_log_metric_filter.metric_filter.id}"
}

output "alarm_id" {
	value = "${aws_cloudwatch_metric_alarm.metric_alarm.id}"
}