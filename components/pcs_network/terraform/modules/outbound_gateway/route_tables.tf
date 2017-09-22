##################################################################
# Outbound Security Gateway app & management route tables

resource "aws_route_table" "ogw_app" {
  vpc_id           = "${var.vpc_id}"
  count            = "${length(var.azs)}"
  propagating_vgws = [
    "${var.vpn_vgw}",
  ]

  tags {
    Name        = "${var.vpc_name}-OGWAPP-NET.RT-LCL-AZ${element(split("-",element(var.azs, count.index)),2)}"
    network     = "Public"
    environment = "${var.environment}"
    lifecycle   = "${var.lifecycle}"
    contact     = "${var.contact}"
  }
}

resource "aws_route" "ogw_app_nat_route" {
  count                  = "${length(var.azs)}"
  route_table_id         = "${element(aws_route_table.ogw_app.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(var.nat_gateway_ids, count.index)}"
}

resource "aws_route" "ogw_app_ecs_route" {
  count                     = "${length(var.ecs_vpc_cidr) > 0 ? length(var.azs) : 0}"
  route_table_id            = "${element(aws_route_table.ogw_app.*.id, count.index)}"
  destination_cidr_block    = "${var.ecs_vpc_cidr}"
  vpc_peering_connection_id = "${var.ecs_vpc_peering_id}"
}

resource "aws_route" "ogw_app_scs_route" {
  count                     = "${length(var.scs_vpc_cidr) > 0 ? length(var.azs) : 0}"
  route_table_id            = "${element(aws_route_table.ogw_app.*.id, count.index)}"
  destination_cidr_block    = "${var.scs_vpc_cidr}"
  vpc_peering_connection_id = "${var.scs_vpc_peering_id}"
}

resource "aws_route_table" "ogw_wkr" {
  vpc_id           = "${var.vpc_id}"
  count            = "${length(var.azs)}"
  propagating_vgws = [
    "${var.vpn_vgw}",
  ]
  tags {
    Name        = "${var.vpc_name}-OGWWKR-NET.RT-INT-AZ${element(split("-",element(var.azs, count.index)),2)}"
    network     = "Internal"
    environment = "${var.environment}"
    lifecycle   = "${var.lifecycle}"
    contact     = "${var.contact}"
  }
}

resource "aws_route" "ogw_mgt_ecs_route" {
  count                     = "${length(var.ecs_vpc_cidr) > 0 ? length(var.azs) : 0}"
  route_table_id            = "${element(aws_route_table.ogw_wkr.*.id, count.index)}"
  destination_cidr_block    = "${var.ecs_vpc_cidr}"
  vpc_peering_connection_id = "${var.ecs_vpc_peering_id}"
}

resource "aws_route" "ogw_mgt_scs_route" {
  count                     = "${length(var.scs_vpc_cidr) > 0 ? length(var.azs) : 0}"
  route_table_id            = "${element(aws_route_table.ogw_wkr.*.id, count.index)}"
  destination_cidr_block    = "${var.scs_vpc_cidr}"
  vpc_peering_connection_id = "${var.scs_vpc_peering_id}"
}
