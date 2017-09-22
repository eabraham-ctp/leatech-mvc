# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# One time resources for Bootstrap Process
#
#

output "kms_key" {
  value = "${aws_kms_key.ami_key.arn}"
}