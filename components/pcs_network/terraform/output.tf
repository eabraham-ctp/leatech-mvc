# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# VPC (simple)

output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "vpc_name" {
  value = "${module.vpc.vpc_name}"
}

output "vpc_cidr" {
  value = "${var.vpc_cidr}"
}

output "azs" {
  value = "${var.azs}"
}

output "dmz_subnets_ids" {
  value = "${module.dmz_subnets.subnet_ids}"
}

output "service_subnet_ids" {
  value = "${module.service_subnets.subnet_ids}"
}

output "data_subnet_ids" {
  value = "${module.data_subnets.subnet_ids}"
}

output "security_subnet_ids" {
  value = "${module.security_subnets.subnet_ids}"
}

output "workstation_subnet_ids" {
  value = "${module.workstation_subnets.subnet_ids}"
}

output "VPC_Endpoint" {
  value = "${aws_vpc_endpoint.S3-Endpoint.id}"
}

output "s3_association_ids" {
  value = "${
    concat (
      module.dmz_subnets.s3_association_id,
      module.service_subnets.s3_association_id,
      module.data_subnets.s3_association_id,
      module.security_subnets.s3_association_id,
      module.workstation_subnets.s3_association_id,
    )
  }"
}

output "s3_endpoint_prefix_id" {
  value = "${aws_vpc_endpoint.S3-Endpoint.prefix_list_id}"
}

# Common Services Security Group 
output "common_sg" {
  value = "${aws_security_group.common_services_group.id}"
}

# Security Services Security Group 
output "sec_service_sg" {
  value = "${aws_security_group.security_services_group.id}"
}

# SSH Security Group 
output "ssh_sg" {
  value = "${aws_security_group.ssh_sg.id}"
}

# RDP Security Group output only exists if workstations subnets defined
output "rdp_sg" {
  value = "${aws_security_group.rdp_sg.id}"
}

# OpenVPN security used to by modules security groups to give access to clients
output "openvpn_sg" {
  value = "${module.openvpn.openvpn_sg}"
}

output "openvpn_address" {
  value = "${module.openvpn.openvpn_address}"
}

output "vpn_gateway_id" {
  value = "${module.vpn.vpn_gateway_id}"
}

output "static_routes" {
  value = "${var.static_routes}"
}


output "vpn_count" {
    value = "${module.vpn.vpn_count}"
}

output "cgw_ids" {
    value = "${module.vpn.cgw_ids}"
}
output "conn_names" {
    value = "${module.vpn.conn_names}"
}
output "tunnel_configs" {
    value = "${module.vpn.tunnel_configs}"
}
