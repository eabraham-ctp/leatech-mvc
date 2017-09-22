# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Common network modules
# Subnets - Base Subnet
#
# NACL resources for private subnets.

resource "aws_network_acl" "base_nacl" {
  count             = "${length(var.subnet_cidrs) > 0 ? 1 : 0}"
  vpc_id            = "${var.vpc_id}"
  subnet_ids        = [
                        "${aws_subnet.base_subnet.*.id}"
                      ]
  tags              = "${merge(var.default_tags, map("Name", format("%s-%s-PVT-NACL", var.org, var.environment)))}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_network_acl_rule" "dmz_ingress_100" {
  count          = "${length(var.subnet_cidrs) > 0 ? 1 : 0}"  
  network_acl_id = "${aws_network_acl.base_nacl.id}"
  egress         = false
  rule_number    = 100
  rule_action    = "allow"
  protocol       = "all"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "dmz_egress_100" {
  count          = "${length(var.subnet_cidrs) > 0 ? 1 : 0}"  
  network_acl_id = "${aws_network_acl.base_nacl.id}"
  egress         = true
  rule_number    = 100
  rule_action    = "allow"
  protocol       = "all"
  cidr_block     = "0.0.0.0/0"
}
