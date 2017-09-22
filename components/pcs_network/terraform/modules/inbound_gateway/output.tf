##################################################################
# Inbound Web Application Firewall Outputs
# see inbound_gateway.tf for more details

output "app_nacl_id" {
  value = "${aws_network_acl.inbound_gateway_app.id}"
}

output "mgt_nacl_id" {
  value = "${aws_network_acl.inbound_gateway_mgt.id}"
}

output "app_rt_id" {
  value = "${aws_route_table.igw_app.id}"
}

output "mgt_rt_id" {
  value = "${aws_route_table.igw_mgt.id}"
}

output "app_subnet_ids" {
  value = "${join(",", aws_subnet.inbound_gateway_app.*.id)}"
}

output "mgt_subnet_ids" {
  value = "${join(",", aws_subnet.inbound_gateway_mgt.*.id)}"
}
