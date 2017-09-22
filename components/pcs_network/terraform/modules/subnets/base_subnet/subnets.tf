# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Common network modules
# Subnets - Base Subnet
#
# Subnet resources for private subnet groups
# Creates one subnet per availability zone with the same name prefix (App, Web, Data, etc)

data "aws_vpc" "selected" {
  id = "${var.vpc_id}"
}

resource "aws_subnet" "base_subnet" {
  count             = "${length(var.subnet_cidrs)}"
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${element(var.subnet_cidrs, count.index)}"
  availability_zone = "${element(var.azs, count.index)}"
  tags = "${merge(var.default_tags, map("Name", format("%s-%s-%s-PVT-%s-SBT", var.org, var.environment, element(var.azs, count.index), var.subnet_name)))}"
  map_public_ip_on_launch = false
}

resource "aws_route_table_association" "subnet_rt_assoc" {
  count          = "${length(var.subnet_cidrs)}"
  subnet_id      = "${element(aws_subnet.base_subnet.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.base_route_table.*.id, count.index)}"
}
