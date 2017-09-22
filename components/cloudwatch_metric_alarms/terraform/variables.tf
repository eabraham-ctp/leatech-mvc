# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# CIS 3.x CloudWatch Metrics & Alarms

variable "cloudtrail_logs_group" {
	description = "Name of Cloud Trail Log Group"
	default = "CloudTrail/DefaultLogGroup"
}

variable "region" {
	description = "region to deploy to"
}
