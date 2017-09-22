# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Common network modules
# Subnets - Base Subnet
#
# Route table resources for private subnets

resource "aws_route_table" "base_route_table" {
  count                     = "${length(var.subnet_cidrs)}"
  vpc_id                    = "${var.vpc_id}"
  propagating_vgws          = ["${var.vpn_vgw_ids}"]
  tags                      = "${merge( 
                                        var.default_tags, 
                                        map(
                                          "Name", 
                                          format(
                                            "%s-%s-%s-PVT-RTB",
                                            var.org, 
                                            var.environment,
                                            var.subnet_name
                                          )
                                        )
                                      )
                                }"
}

# Route to PCS VPC across peering, if present
resource "aws_route" "base_subnet_pcs_route" {
  count                     = "${length(var.pcs_vpc_peering_id) > 0 ? length(var.subnet_cidrs) : 0}"
  route_table_id            = "${element(aws_route_table.base_route_table.*.id, count.index)}"
  destination_cidr_block    = "${var.pcs_vpc_cidr}"
  vpc_peering_connection_id = "${var.pcs_vpc_peering_id}"
}

# Route to PSS VPC across peering, if present
resource "aws_route" "base_subnet_pss_route" {
  count                     = "${length(var.pss_vpc_peering_id) > 0 ? length(var.subnet_cidrs) : 0}"
  route_table_id            = "${element(aws_route_table.base_route_table.*.id, count.index)}"
  destination_cidr_block    = "${var.pss_vpc_cidr}"
  vpc_peering_connection_id = "${var.pss_vpc_peering_id}"
}

# Default route to the internet, through the provided NAT gateways
resource "aws_route" "base_subnet_outbound_route" {
  count                     = "${length(var.subnet_cidrs)}"
  route_table_id            = "${element(aws_route_table.base_route_table.*.id, count.index)}"
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            = "${element(var.nat_gateway_ids, count.index)}"
}

# Route to S3 endpoint if available
resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  count                     = "${length(var.subnet_cidrs)}"
  vpc_endpoint_id           = "${var.s3endpoint}"
  route_table_id            = "${element(aws_route_table.base_route_table.*.id, count.index)}"
}

# Add static routes via peering the route table must already have route propagation turned on otherwise this will fail
resource "aws_route" "base_subnet_static_route" {
  count                     = "${length(var.static_routes) > 0 ? length(var.subnet_cidrs) : 0}"
  route_table_id            = "${element(aws_route_table.base_route_table.*.id, count.index)}"
  destination_cidr_block    = "${var.static_routes}"
  gateway_id                = "${element(var.vpn_vgw_ids,0)}"
}
