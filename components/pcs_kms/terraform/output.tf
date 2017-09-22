# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# One time resources for Bootstrap Process
#
#

output "pcs_ami_kms" {
  value = "${module.pcs_ami_kms.kms_key}"
}

output "pcs_general_kms" {
  value = "${module.pcs_general_kms.kms_key}"
}
