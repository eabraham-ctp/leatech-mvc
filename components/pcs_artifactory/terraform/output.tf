# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# artifactory

output "instance_id" {
  value = "${module.pcs_artifactory.instance_id}"
}

output "instance_address" {
  value = "${module.pcs_artifactory.instance_address}"
}
