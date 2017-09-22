# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Squid

output "squid_instance_profile" {
  value = "${aws_iam_instance_profile.squid_instance_profile.arn}"
}

output "squid_conf_prefix" {
  value = "${var.squid_conf_prefix}"
}
