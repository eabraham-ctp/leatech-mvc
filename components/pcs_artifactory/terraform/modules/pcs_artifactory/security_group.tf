# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# artifactory
#
# Creates a artifactory server (or cluster) for Platform Common Services (PCS).

resource "aws_security_group" "artifactory" {
  name        = "${format("%s-%s-Artifactory-SG", var.org, var.environment)}"
  description = "artifactory internal traffic, administration, and UI"
  vpc_id      = "${var.vpc_id}"
  tags        = "${merge(var.default_tags, map("Name", format("%s-%s-Artifactory-SG", var.org, var.environment)))}"
}


###############################################
# Ingress - Global
###############################################

# Ingress allow from common_sg
resource "aws_security_group_rule" "sg_ingress_from_common_sg" {
  type = "ingress"
  security_group_id        = "${aws_security_group.artifactory.id}"
  from_port                = "8443"
  to_port                  = "8443"
  protocol                 = "TCP"
  source_security_group_id = "${var.common_sg}" 
}

# Egress added to common_sg
resource "aws_security_group_rule" "common_sg_to_app_sg" {
  type                     = "egress"
  security_group_id        = "${var.common_sg}"
  from_port                = "8443"
  to_port                  = "8443"
  protocol                 = "TCP"
  source_security_group_id = "${aws_security_group.artifactory.id}"
}
