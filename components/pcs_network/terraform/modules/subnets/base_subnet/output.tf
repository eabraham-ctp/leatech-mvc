# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Common network modules
# Subnets - Base Subnet

output "nacl_id" {
  value = "${aws_network_acl.base_nacl.id}"
}

output "subnet_ids" {
  value = ["${aws_subnet.base_subnet.*.id}"]
}

output "s3_association_id" {
  value = "${aws_vpc_endpoint_route_table_association.private_s3.*.id}"
}

output "base_subnet_pcs_route_ids" {
  value = ["${aws_route.base_subnet_pcs_route.*.id}"]
}

# Duplicate of base_subnet_pcs_route_ids for standardisation of names
output "aws_route_table_ids" {
  value = ["${aws_route_table.base_route_table.*.id}"]
}
