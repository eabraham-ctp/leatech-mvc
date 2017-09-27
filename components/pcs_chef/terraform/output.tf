# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Chef - bootstrap

output "chef_address" {
  value = "${module.pcs_chef.priv_address}"
}

output "chef_elb_address" {
  value = "${module.pcs_chef.elb_address}"
}

output "admin_username" {
  value = "${module.pcs_chef.admin_username}"
}
