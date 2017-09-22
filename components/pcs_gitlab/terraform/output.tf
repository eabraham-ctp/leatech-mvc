# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Gitlab

output "instance_id" {
  value = "${module.pcs_gitlab.instance_id}"
}

output "instance_address" {
  value = "${module.pcs_gitlab.instance_address}"
}

output "gitlab_sg_id" {
  value = "${module.pcs_gitlab.gitlab_sg_id}"
}

output "instance_profile_name" {
  value = "${module.pcs_gitlab.instance_profile_name}"
}
