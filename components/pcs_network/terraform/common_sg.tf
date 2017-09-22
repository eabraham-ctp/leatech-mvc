# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Access control (simple)
#
# Control Services group applied to all machines

###############################################
#
# Common Services Security Group
#

resource "aws_security_group" "common_services_group" {
  name              = "${var.org}-${var.environment}-CommonServices-SG"
  description       = "Internal traffic, administration, and UI"
  vpc_id            = "${module.vpc.vpc_id}"
  tags              = "${merge(var.default_tags, map("Name", format("%s-%s-CommonServices-SG", var.org, var.environment)))}"
}


###############################################
# Egress - Global
###############################################

# DNS access inside VPC
resource "aws_security_group_rule" "egress_DNS" {
  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  cidr_blocks       = ["${var.vpc_cidr}"]
  security_group_id = "${aws_security_group.common_services_group.id}"
}

# NTP access inside VPC
resource "aws_security_group_rule" "egress_NTP" {
  type              = "egress"
  from_port         = 123
  to_port           = 123
  protocol          = "udp"
  cidr_blocks       = ["${var.vpc_cidr}"]
  security_group_id = "${aws_security_group.common_services_group.id}"
}

# AWS metadata service
resource "aws_security_group_rule" "egress_aws_metadata" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["169.254.169.254/32"]
  security_group_id = "${aws_security_group.common_services_group.id}"
}