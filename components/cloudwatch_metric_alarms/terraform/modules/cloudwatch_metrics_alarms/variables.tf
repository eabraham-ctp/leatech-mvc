# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# CIS 3.x CloudWatch Metrics & Alarms

variable "cloudtrail_logs_group" {
	description = "Name of Cloud Trail Log Group"
}

variable "alert_topic" {
	description = "topic to send alerts to"
}
variable "metric_name"{
	description = "A name for the metric filter."
}
variable "metric_pattern"{
	description = "A valid CloudWatch Logs filter pattern for extracting metric data out of ingested log events."
}
variable "metric_transformation_name" {
	description = "The name of the CloudWatch metric to which the monitored log information should be published (e.g. ErrorCount)"
}
variable "metric_transformation_namespace" {
	description = "The destination namespace of the CloudWatch metric."
}
variable "metric_transformation_value" {
	description = "What to publish to the metric."
}
variable "alarm_name" {
	description = "The descriptive name for the alarm. This name must be unique within the user's AWS account."
}
variable "alarm_comparison_operator" {
	description = "The arithmetic operation to use when comparing the specified Statistic and Threshold. The specified Statistic value is used as the first operand. Either of the following is supported: GreaterThanOrEqualToThreshold, GreaterThanThreshold, LessThanThreshold, LessThanOrEqualToThreshold."
}
variable "alarm_evaluation_periods" {
	description = "The number of periods over which data is compared to the specified threshold."
}
variable "alarm_period" {
	description = "The period in seconds over which the specified statistic is applied."
}
variable "alarm_statistic" {
	description = "The statistic to apply to the alarm's associated metric. Either of the following is supported: SampleCount, Average, Sum, Minimum, Maximum"
}
variable "alarm_threshold" {
	description = "The value against which the specified statistic is compared."
}
variable "alarm_description" {
	description = "The description for the alarm."
}
variable "alarm_treat_missing_data" {
	description = "Sets how this alarm is to handle missing data points. The following values are supported: missing, ignore, breaching and notBreaching. Defaults to missing."
}
variable "alarm_insufficient_action" {
	description = "The list of actions to execute when this alarm transitions into an INSUFFICIENT_DATA state from any other state. Each action is specified as an Amazon Resource Number (ARN)."
	type = "list"
	default = []
}
