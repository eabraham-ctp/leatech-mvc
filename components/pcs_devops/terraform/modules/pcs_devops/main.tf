# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# DEVOPS workspace 
#

resource "aws_security_group" "devops" {
  name                      = "${var.org}-${var.environment}-Devops-SG"
  description               = "DEVOPS access to Services"
  vpc_id                    = "${var.vpc_id}"
  tags                      = "${merge(var.default_tags, map("Name", format("%s-%s-Devops-SG", var.org, var.environment)))}"
}


###############################################
# Egress - Global
###############################################

# Consul access
resource "aws_security_group_rule" "egress_consul" {
  count                     = "${length(var.consul_sg_ids)}"
  type                      = "egress"
  from_port                 = 8500
  to_port                   = 8500
  protocol                  = "tcp"
  source_security_group_id  = "${element(var.consul_sg_ids,count.index)}"
  security_group_id         = "${aws_security_group.devops.id}"
}

# Vault access
resource "aws_security_group_rule" "egress_vault" {
  type                      = "egress"
  from_port                 = 8200
  to_port                   = 8200
  protocol                  = "tcp"
  source_security_group_id  = "${element(var.vault_sg_ids,count.index)}"
  security_group_id         = "${aws_security_group.devops.id}"
}

# SSH access
resource "aws_security_group_rule" "egress_ssh" {
  type                      = "egress"
  from_port                 = 22
  to_port                   = 22
  protocol                  = "tcp"
  source_security_group_id  = "${element(var.ssh_sg_ids,count.index)}"
  security_group_id         = "${aws_security_group.devops.id}"
}

###############################################
# Ingress - Global
###############################################

# Consul access
resource "aws_security_group_rule" "ingress_consul" {
  count                     = "${length(var.consul_sg_ids)}"
  type                      = "ingress"
  from_port                 = 8500
  to_port                   = 8500
  protocol                  = "tcp"
  security_group_id         = "${element(var.consul_sg_ids,count.index)}"
  source_security_group_id  = "${aws_security_group.devops.id}"
}

# Vault access
resource "aws_security_group_rule" "ingress_vault" {
  type                      = "ingress"
  from_port                 = 8200
  to_port                   = 8200
  protocol                  = "tcp"
  security_group_id         = "${element(var.vault_sg_ids,count.index)}"
  source_security_group_id  = "${aws_security_group.devops.id}"
}

# SSH access
resource "aws_security_group_rule" "ingress_ssh" {
  type                      = "ingress"
  from_port                 = 22
  to_port                   = 22
  protocol                  = "tcp"
  security_group_id         = "${element(var.ssh_sg_ids,count.index)}"
  source_security_group_id  = "${aws_security_group.devops.id}"
}