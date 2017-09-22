# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Common network modules
# Subnets - DMZ
#
# Internet gateway for DMZs

resource "aws_internet_gateway" "igw" {
  vpc_id = "${var.vpc_id}"
  tags   = "${merge(var.default_tags, map("Name", format("%s-%s-IGW", var.org, var.environment)))}"
}
