# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Common network modules
# Subnets - DMZ
#
# Subnets for DMZs

data "aws_vpc" "selected" {
  id = "${var.vpc_id}"
}

resource "aws_subnet" "dmz" {
  count                   = "${length(var.azs)}"

  vpc_id                  = "${var.vpc_id}"
  cidr_block              = "${element(var.subnet_cidrs, count.index)}"
  availability_zone       = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = true

  tags = "${merge(var.default_tags, map("Name", format("%s-%s-%s-PUB-%s-SBT", var.org, var.environment, element(var.azs, count.index), var.subnet_name)))}"
}

resource "aws_route_table_association" "dmz" {
  count          = "${length(var.azs)}"
  subnet_id      = "${element(aws_subnet.dmz.*.id, count.index)}"
  route_table_id = "${aws_route_table.dmz.id}"
}
