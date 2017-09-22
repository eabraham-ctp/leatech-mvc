#--------------------------------------------------------------
# This module creates subnets and resources necessary for
# creating Outbound Security Gateway infrastructure
#--------------------------------------------------------------

output "app_nacl_id" {
  value = "${aws_network_acl.ogw_app.id}"
}

output "mgt_nacl_id" {
  value = "${aws_network_acl.ogw_wkr.id}"
}

output "app_subnet_ids" {
  value = "${join(",", aws_subnet.ogw_app.*.id)}"
}

output "mgt_subnet_ids" {
  value = "${join(",", aws_subnet.ogw_wkr.*.id)}"
}
