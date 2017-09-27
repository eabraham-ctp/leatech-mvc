# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Jenkins - Output
#
# Module for creating the Jenkins Service for Platform Common Services (PCS). This version uses
# Chef cookbooks on top of the Terraform scripts

output "instance_id" {
  value = "${module.pcs_jenkins.instance_id}"
}

output "pub_address" {
  value = "${module.pcs_jenkins.pub_address}"
}

output "priv_address" {
  value = "${module.pcs_jenkins.priv_address}"
}

output "security_group_id" {
  value = "${module.pcs_jenkins.security_group_id}"
}

output "elb_address" {
  value = "${module.pcs_jenkins.elb_address}"
}
