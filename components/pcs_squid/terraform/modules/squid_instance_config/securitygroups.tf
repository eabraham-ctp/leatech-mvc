###############################################
#
# Squid ELB Security Group
#

resource "aws_security_group" "sg_squid_elb"{
  name        = "${var.org}-${var.environment}-SquidELB-SG"

  tags        = "${merge(var.default_tags, map("Name", format("%s-%s-SquidELB-SG", var.org, var.environment)))}"
  vpc_id      = "${var.vpc_id}"
}

# Ingress
resource "aws_security_group_rule" "sg_squid_elb_ingress" {
  type = "ingress"
  security_group_id = "${aws_security_group.sg_squid_elb.id}"
  from_port                = "${var.squid_port}"
  to_port                  = "${var.squid_port}"
  protocol                 = "TCP"
  source_security_group_id = "${var.common_sg}" 
}

# Egress for ELB SG
resource "aws_security_group_rule" "sg_squid_elb_egress" {
  type = "egress"
  security_group_id        = "${aws_security_group.sg_squid_elb.id}"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "TCP"
  source_security_group_id = "${aws_security_group.sg_squid_instances.id}"
}

# Egress added to common_sg
resource "aws_security_group_rule" "common_sg_proxy_access" {
  type = "egress"
  security_group_id        = "${var.common_sg}"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "TCP"
  source_security_group_id = "${aws_security_group.sg_squid_elb.id}"
}
###############################################
#
# Squid Instances Security Group
#

resource "aws_security_group" "sg_squid_instances" {
  name        = "${var.org}-${var.environment}-SquidEC2-SG"  
  tags        = "${merge(var.default_tags, map("Name", format("%s-%s-SquidEC2-SG", var.org, var.environment)))}"
  vpc_id      = "${var.vpc_id}"
}

# Access from the ELB
resource "aws_security_group_rule" "sg_squid_instance_ingress_web" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.sg_squid_instances.id}"
  from_port                = "${var.squid_port}"
  to_port                  = "${var.squid_port}"
  protocol                 = "TCP"
  source_security_group_id = "${aws_security_group.sg_squid_elb.id}"
}

# Egress

resource "aws_security_group_rule" "sg_squid_instance_egress_tcp" {
  count             = "${length(var.squid_egress_ports)}"
  type              = "egress"
  security_group_id = "${aws_security_group.sg_squid_instances.id}"
  from_port         = "${element(split("|" ,element(var.squid_egress_ports, count.index)), 1)}"
  to_port           = "${element(split("|" ,element(var.squid_egress_ports, count.index)), 1)}"
  protocol          = "TCP"
  cidr_blocks       = ["${element(split("|" ,element(var.squid_egress_ports, count.index)), 0)}"] 
}
