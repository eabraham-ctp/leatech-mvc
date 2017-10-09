# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Gitlab

output "instance_id" {
  value = "${aws_instance.gitlab.id}"
}

output "instance_address" {
  value = "${aws_instance.gitlab.private_ip}"
}

output "gitlab_sg_id" {
  value = "${aws_security_group.gitlab.id}"
}

output "instance_profile_name" {
  value = "${aws_iam_instance_profile.gitlab_instance_profile.name}"
}

output "no_proxy" {
  value = "${var.no_proxy}"
}
