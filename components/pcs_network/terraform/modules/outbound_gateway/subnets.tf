##################################################################
# Outbound Security Gateway app & management subnets

resource "aws_subnet" "ogw_app" {
  vpc_id                  = "${var.vpc_id}"
  cidr_block              = "${cidrsubnet(var.vpc_cidr, var.cidr_newbits, var.cidr_network_start + count.index)}"
  availability_zone       = "${element(var.azs, count.index)}"
  count                   = "${length(var.azs)}"

  tags {
    Name        = "${var.vpc_name}-OGWAPP-NET.SUB-INT-AZ${element(split("-",element(var.azs, count.index)),2)}"
    network     = "Internal"
    environment = "${var.environment}"
    lifecycle   = "${var.lifecycle}"
    contact     = "${var.contact}"
  }
  map_public_ip_on_launch = false
}

resource "aws_subnet" "ogw_wkr" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${cidrsubnet(var.vpc_cidr, var.cidr_newbits, var.cidr_network_start + length(var.azs) + count.index)}"
  availability_zone = "${element(var.azs, count.index)}"
  count             = "${length(var.azs)}"

  tags {
    Name        = "${var.vpc_name}-OGWWKR-NET.SUB-INT-AZ${element(split("-",element(var.azs, count.index)),2)}"
    network     = "Internal"
    environment = "${var.environment}"
    lifecycle   = "${var.lifecycle}"
    contact     = "${var.contact}"
  }
}

resource "aws_route_table_association" "ogw_app_rt_assoc" {
  count          = "${length(var.azs)}"
  subnet_id      = "${element(aws_subnet.ogw_app.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.ogw_app.*.id, count.index)}"
}

resource "aws_route_table_association" "ogw_wkr_rt_assoc" {
  count          = "${length(var.azs)}"
  subnet_id      = "${element(aws_subnet.ogw_wkr.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.ogw_wkr.*.id, count.index)}"
}

