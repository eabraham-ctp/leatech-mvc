# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Common network modules
# Subnets - DMZ
#
# NAT Gateway for DMZ, with attached EIP

resource "aws_eip" "nat" {
  vpc   = true
  count = "${length(var.azs)}"
}

resource "aws_nat_gateway" "nat" {
  count         = "${length(var.azs)}"
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.dmz.*.id, count.index)}"
}
