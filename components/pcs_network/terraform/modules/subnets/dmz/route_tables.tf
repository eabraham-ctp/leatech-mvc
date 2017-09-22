# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Common network modules
# Subnets - DMZ
#
# Route tables for DMZs

resource "aws_route_table" "dmz" {
  vpc_id                    = "${var.vpc_id}"
  propagating_vgws          = ["${var.vpn_vgw_ids}"]
  tags                      = "${merge(var.default_tags, map("Name", format("%s-%s-%s-PUB-RTB", var.org, var.environment, var.subnet_name)))}"
}

resource "aws_route" "dmz_igw" {
  route_table_id            = "${aws_route_table.dmz.id}"
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = "${aws_internet_gateway.igw.id}"
}

# Route to S3 endpoint if available
resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  vpc_endpoint_id           = "${var.s3endpoint}"
  route_table_id            = "${element(aws_route_table.dmz.*.id, count.index)}"
}
