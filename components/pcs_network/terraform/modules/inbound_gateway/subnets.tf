##################################################################
# Inbound Web Application Firewall app & management subnets
# see inbound_gateway.tf for more details

resource "aws_subnet" "inbound_gateway_app" {
  vpc_id                  = "${var.vpc_id}"
  cidr_block              = "${cidrsubnet(var.vpc_cidr, var.cidr_newbits, var.cidr_network_start + count.index)}"
  availability_zone       = "${element(var.azs, count.index)}"
  count                   = "${length(var.azs)}"

  tags {
    Name        = "${var.vpc_name}-WAFAPP-NET.SUB-INT-AZ${element(split("-",element(var.azs, count.index)),2)}"
    network     = "Internal"
    environment = "${var.environment}"
    lifecycle   = "${var.lifecycle}"
    contact     = "${var.contact}"
  }
  map_public_ip_on_launch = false
}

resource "aws_subnet" "inbound_gateway_mgt" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${cidrsubnet(var.vpc_cidr, var.cidr_newbits, var.cidr_network_start + length(var.azs) + count.index)}"
  availability_zone = "${element(var.azs, count.index)}"
  count             = "${length(var.azs)}"

  tags {
    Name        = "${var.vpc_name}-WAFMGT-NET.SUB-INT-AZ${element(split("-",element(var.azs, count.index)),2)}"
    network     = "Internal"
    environment = "${var.environment}"
    lifecycle   = "${var.lifecycle}"
    contact     = "${var.contact}"
  }
}

resource "aws_route_table_association" "inbound_gateway_app" {
  count          = "${length(var.azs)}"
  subnet_id      = "${element(aws_subnet.inbound_gateway_app.*.id, count.index)}"
  route_table_id = "${aws_route_table.igw_app.id}"
}

resource "aws_route_table_association" "inbound_gateway_mgt" {
  count          = "${length(var.azs)}"
  subnet_id      = "${element(aws_subnet.inbound_gateway_mgt.*.id, count.index)}"
  route_table_id = "${aws_route_table.igw_mgt.id}"
}
