##################################################################
# Outbound Security Gateway main network access NACLs

resource "aws_network_acl" "ogw_app" {
  vpc_id = "${var.vpc_id}"
  subnet_ids = [
    "${aws_subnet.ogw_app.*.id}",
  ]
  tags {
    Name        = "${var.vpc_name}-OGWAPP-NET.ACL-INT"
    network     = "Internal"
    environment = "${var.environment}"
    lifecycle   = "${var.lifecycle}"
    contact     = "${var.contact}"
  }
}

resource "aws_network_acl_rule" "ogw_app_ingress_100" {
  network_acl_id = "${aws_network_acl.ogw_app.id}"
  egress         = false
  rule_number    = 100
  rule_action    = "allow"
  protocol       = "all"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "ogw_app_egress_100" {
  network_acl_id = "${aws_network_acl.ogw_app.id}"
  egress         = true
  rule_number    = 100
  rule_action    = "allow"
  protocol       = "all"
  cidr_block     = "0.0.0.0/0"
}

##################################################################
# Outbound Security Gateway management network access NACLs

resource "aws_network_acl" "ogw_wkr" {
  vpc_id = "${var.vpc_id}"
  subnet_ids = [
    "${aws_subnet.ogw_wkr.*.id}",
  ]
  tags {
    Name        = "${var.vpc_name}-OGWWKR-NET.ACL-INT"
    network     = "Internal"
    environment = "${var.environment}"
    lifecycle   = "${var.lifecycle}"
    contact     = "${var.contact}"
  }
}

resource "aws_network_acl_rule" "ogw_wkr_ingress_100" {
  network_acl_id = "${aws_network_acl.ogw_wkr.id}"
  egress         = false
  rule_number    = 100
  rule_action    = "allow"
  protocol       = "all"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "ogw_wkr_egress_100" {
  network_acl_id = "${aws_network_acl.ogw_wkr.id}"
  egress         = true
  rule_number    = 100
  rule_action    = "allow"
  protocol       = "all"
  cidr_block     = "0.0.0.0/0"
}
