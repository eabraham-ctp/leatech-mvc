##################################################################
# Inbound Web Application Firewall main network access NACLs
# see inbound_gateway.tf for more details

resource "aws_network_acl" "inbound_gateway_app" {
  vpc_id = "${var.vpc_id}"

  subnet_ids = [
    "${aws_subnet.inbound_gateway_app.*.id}",
  ]

  tags {
    Name        = "${var.vpc_name}-WAFAPP-NET.ACL-INT"
    network     = "Internal"
    environment = "${var.environment}"
    lifecycle   = "${var.lifecycle}"
    contact     = "${var.contact}"
  }
}

resource "aws_network_acl_rule" "inbound_gateway_app_ingress_100" {
  network_acl_id = "${aws_network_acl.inbound_gateway_app.id}"
  egress         = false
  rule_number    = 100
  rule_action    = "allow"
  protocol       = "all"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "inbound_gateway_app_egress_100" {
  network_acl_id = "${aws_network_acl.inbound_gateway_app.id}"
  egress         = true
  rule_number    = 100
  rule_action    = "allow"
  protocol       = "all"
  cidr_block     = "0.0.0.0/0"
}

##################################################################
# Inbound Web Application Firewall management network access NACLs

resource "aws_network_acl" "inbound_gateway_mgt" {
  vpc_id = "${var.vpc_id}"

  subnet_ids = [
    "${aws_subnet.inbound_gateway_mgt.*.id}",
  ]

  tags {
    Name        = "${var.vpc_name}-WAFMGT-NET.ACL-INT"
    network     = "Internal"
    environment = "${var.environment}"
    lifecycle   = "${var.lifecycle}"
    contact     = "${var.contact}"
  }
}

resource "aws_network_acl_rule" "inbound_gateway_mgt_ingress_100" {
  network_acl_id = "${aws_network_acl.inbound_gateway_mgt.id}"
  egress         = false
  rule_number    = 100
  rule_action    = "allow"
  protocol       = "all"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "inbound_gateway_mgt_egress_100" {
  network_acl_id = "${aws_network_acl.inbound_gateway_mgt.id}"
  egress         = true
  rule_number    = 100
  rule_action    = "allow"
  protocol       = "all"
  cidr_block     = "0.0.0.0/0"
}