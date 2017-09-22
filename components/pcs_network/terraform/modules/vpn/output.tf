##################################################################
# VPN Connection Variables
# see vpn.tf for more details

output "vpn_count" {
  value = "${count(var.vpn_conn_config)}"
}

output "vpn_gateway_id" {
  value = "${join("", aws_vpn_gateway.vpn_gateway.*.id)}"
}

output "vpn_gateway_name" {
  value = "${aws_vpn_gateway.vpn_gateway.tags.Name}"
}

output "cgw_ids" {
  value = "${join(",", aws_customer_gateway.customer_gateways.*.id)}"
}

output "conn_names" {
  value = "${join( ",", aws_vpn_connection.conns.*.tags.Name)}"
}

output "tunnel_configs" {
  value = "${join( ",", aws_vpn_connection.conns.*.customer_gateway_configuration)}"
}

output "vpn_gw_boolean" {
  value = "true"
}
