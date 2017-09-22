# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Common network modules
# Subnets - DMZ

output "nacl_id" {
  value = "${aws_network_acl.dmz.id}"
}

output "subnet_ids" {
  value = ["${aws_subnet.dmz.*.id}"]
}

output "igw_id" {
  value = "${aws_internet_gateway.igw.id}"
}

output "nat_gateway_ids" {
  value = ["${aws_nat_gateway.nat.*.id}"]
}

output "s3_association_id" {
  value = "${aws_vpc_endpoint_route_table_association.private_s3.*.id}"
}

output "aws_route_table_ids" {
  value = "${aws_route_table.dmz.*.id}"
}
