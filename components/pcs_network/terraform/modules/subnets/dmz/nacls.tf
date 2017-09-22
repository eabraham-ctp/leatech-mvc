# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Common network modules
# Subnets - DMZ
#
# NACLs for DMZs

resource "aws_network_acl" "dmz" {
  vpc_id     = "${var.vpc_id}"

  subnet_ids = [
    "${aws_subnet.dmz.*.id}"
  ]

  tags   = "${merge(var.default_tags, map("Name", format("%s-%s-PUB-NACL", var.org, var.environment)))}"
}

resource "aws_network_acl_rule" "dmz_ingress_100" {
  network_acl_id = "${aws_network_acl.dmz.id}"
  egress         = false
  rule_number    = 100
  rule_action    = "allow"
  protocol       = "all"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "dmz_egress_100" {
  network_acl_id = "${aws_network_acl.dmz.id}"
  egress         = true
  rule_number    = 100
  rule_action    = "allow"
  protocol       = "all"
  cidr_block     = "0.0.0.0/0"
}
