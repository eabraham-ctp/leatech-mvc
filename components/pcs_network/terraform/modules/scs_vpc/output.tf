##################################################################
# Security Common Services(SCS) VPC Outputs
# see scs_vpc.tf for more details

output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "vpc_cidr" {
  value = "${aws_vpc.vpc.cidr_block}"
}

output "vpc_name" {
  value = "${var.vpc_name}"
}

output "main_route_table_id" {
  value = "${aws_vpc.vpc.main_route_table_id}"
}

output "default_network_acl_id" {
  value = "${aws_vpc.vpc.default_network_acl_id}"
}
