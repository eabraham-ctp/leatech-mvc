##################################################################
# Inbound Web Application Firewall app & management route tables
# see inbound_gateway.tf for more details

resource "aws_route_table" "igw_app" {
  vpc_id           = "${var.vpc_id}"

  propagating_vgws = [
    "${var.vpn_vgw}",
  ]

  tags {
    Name        = "${var.vpc_name}-WAFAPP-NET.RT-INT"
    network     = "Internal"
    environment = "${var.environment}"
    lifecycle   = "${var.lifecycle}"
    contact     = "${var.contact}"
  }
}

resource "aws_route" "igw_app_ecs_route" {
  count                     = "${length(var.ecs_vpc_cidr) > 0 ? 1 : 0}"
  route_table_id            = "${aws_route_table.igw_app.id}"
  destination_cidr_block    = "${var.ecs_vpc_cidr}"
  vpc_peering_connection_id = "${var.ecs_vpc_peering_id}"
}

resource "aws_route" "igw_app_scs_route" {
  count                     = "${length(var.scs_vpc_cidr) > 0 ? 1 : 0}"
  route_table_id            = "${aws_route_table.igw_app.id}"
  destination_cidr_block    = "${var.scs_vpc_cidr}"
  vpc_peering_connection_id = "${var.scs_vpc_peering_id}"
}

resource "aws_route_table" "igw_mgt" {
  vpc_id           = "${var.vpc_id}"
  propagating_vgws = [
    "${var.vpn_vgw}",
  ]

  tags {
    Name        = "${var.vpc_name}-WAFMGT-NET.RT-INT"
    network     = "Internal"
    environment = "${var.environment}"
    lifecycle   = "${var.lifecycle}"
    contact     = "${var.contact}"
  }
}

resource "aws_route" "igw_mgt_ecs_route" {
  count                     = "${length(var.ecs_vpc_cidr) > 0 ? 1 : 0}"
  route_table_id            = "${aws_route_table.igw_mgt.id}"
  destination_cidr_block    = "${var.ecs_vpc_cidr}"
  vpc_peering_connection_id = "${var.ecs_vpc_peering_id}"
}

resource "aws_route" "igw_mgt_scs_route" {
  count                     = "${length(var.scs_vpc_cidr) > 0 ? 1 : 0}"
  route_table_id            = "${aws_route_table.igw_mgt.id}"
  destination_cidr_block    = "${var.scs_vpc_cidr}"
  vpc_peering_connection_id = "${var.scs_vpc_peering_id}"
}