# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Splunk - bootstrap

output "splunk_url" {
  value = "http://${module.splunk.url}"
}

output "cloudtrail_sqs_queue" {
  value = "${module.cloudtrail.aws_sqs_queue_url}"
}
