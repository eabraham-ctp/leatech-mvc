# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Gitlab
#
# Creates a Gitlab server for Platform Common Services (PCS).

resource "aws_security_group" "gitlab" {
  name        = "${format("%s-%s-Gitlab-SG", var.org, var.environment)}"
  description = "Gitlab internal traffic, administration, and UI"
  vpc_id      = "${var.vpc_id}"
  tags        = "${merge(var.default_tags, map("Name", format("%s-%s-Gitlab-SG", var.org, var.environment)))}"
}


###############################################
# Ingress - Global
###############################################

# Ingress allow from common_sg
resource "aws_security_group_rule" "elb_sg_ingress_from_common_sg" {
  type = "ingress"
  security_group_id        = "${aws_security_group.gitlab.id}"
  from_port                = "80"
  to_port                  = "80"
  protocol                 = "TCP"
  source_security_group_id = "${var.common_sg}" 
}

# Egress added to common_sg
resource "aws_security_group_rule" "common_sg_egress_to_elb_sg" {
  type                     = "egress"
  security_group_id        = "${var.common_sg}"
  from_port                = "80"
  to_port                  = "80"
  protocol                 = "TCP"
  source_security_group_id = "${aws_security_group.gitlab.id}"
}
