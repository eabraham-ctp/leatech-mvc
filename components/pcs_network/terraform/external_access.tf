# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Access control (simple)
#
# External Access #TECHDEBT Description


###############################################
#
# External SSH only Access
#

resource "aws_security_group" "ssh_sg" {
  name              = "${var.org}-${var.environment}-SshAccess-SG"
  description       = "External SSH access"
  vpc_id            = "${module.vpc.vpc_id}"
  tags              = "${merge(var.default_tags, map("Name", format("%s-%s-SshAccess-SG", var.org, var.environment)))}"
}

###############################################
# Ingress
###############################################

# Initial access from CiDR blocks [optional]
resource "aws_security_group_rule" "ingress_ssh_from_cidr" {
  count             = "${length(var.ssh_cidrs) > 0 ? 1 : 0}"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  cidr_blocks       = ["${var.ssh_cidrs}"]
  security_group_id = "${aws_security_group.ssh_sg.id}"
}

###############################################
#
# OpenVPN base access
#

resource "aws_security_group_rule" "allow_ssh_in_from_openvpn_sg" {
  count                    = "${length(var.openvpn_eip) > 0 ? 1 : 0}" 
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "TCP"
  security_group_id        = "${aws_security_group.ssh_sg.id}"
  source_security_group_id = "${module.openvpn.openvpn_sg}"
}

resource "aws_security_group_rule" "allow_ssh_out_to_ssh_sg" {
  count                    = "${length(var.openvpn_eip) > 0 ? 1 : 0}" 
  type                     = "egress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "TCP"
  source_security_group_id = "${aws_security_group.ssh_sg.id}"
  security_group_id        = "${module.openvpn.openvpn_sg}"
}

# RDP access if RDP security group was defined
resource "aws_security_group_rule" "allow_rdp_out_from_openvpn_sg" {
  count                    = "${length(lookup(var.subnet_cidrs, "Workstations","")) > 0 ? 1 : 0}"
  type                     = "egress"
  from_port                = 3389
  to_port                  = 3389
  protocol                 = "TCP"
  source_security_group_id = "${aws_security_group.rdp_sg.id}"
  security_group_id        = "${module.openvpn.openvpn_sg}"
}

# RDP access if RDP security group was defined
resource "aws_security_group_rule" "allow_rdp_in_from_openvpn_sg" {
  count                    = "${length(lookup(var.subnet_cidrs, "Workstations","")) > 0 ? 1 : 0}"
  type                     = "ingress"
  from_port                = 3389
  to_port                  = 3389
  protocol                 = "TCP"
  security_group_id        = "${aws_security_group.rdp_sg.id}"
  source_security_group_id = "${module.openvpn.openvpn_sg}"
}

resource "aws_security_group_rule" "allow_inbound_consul_from_openvpn_sg" {
  count                    = "${length(var.openvpn_eip) > 0 ? 1 : 0}" 
  type                     = "ingress"
  from_port                = 8500
  to_port                  = 8500
  protocol                 = "TCP"
  security_group_id        = "${aws_security_group.security_services_group.id}"
  source_security_group_id = "${module.openvpn.openvpn_sg}"
}

resource "aws_security_group_rule" "allow_inbound_vault_from_openvpn_sg" {
  count                    = "${length(var.openvpn_eip) > 0 ? 1 : 0}" 
  type                     = "ingress"
  from_port                = 8200
  to_port                  = 8200
  protocol                 = "TCP"
  security_group_id        = "${aws_security_group.security_services_group.id}"
  source_security_group_id = "${module.openvpn.openvpn_sg}"
}

resource "aws_security_group_rule" "allow_consul_outbound_from_openvpn_sg" {
  count                    = "${length(var.openvpn_eip) > 0 ? 1 : 0}" 
  type                     = "egress"
  from_port                = 8500
  to_port                  = 8500
  protocol                 = "TCP"
  security_group_id        = "${module.openvpn.openvpn_sg}"
  source_security_group_id = "${aws_security_group.security_services_group.id}"
}

resource "aws_security_group_rule" "allow_vault_outbound_from_openvpn_sg" {
  count                    = "${length(var.openvpn_eip) > 0 ? 1 : 0}" 
  type                     = "egress"
  from_port                = 8200
  to_port                  = 8200
  protocol                 = "TCP"
  security_group_id        = "${module.openvpn.openvpn_sg}"
  source_security_group_id = "${aws_security_group.security_services_group.id}"
}
###############################################
#
# External RDP only Access - Only built if Workstation subnets have been defined
#

resource "aws_security_group" "rdp_sg" {
  count                    = "${length(lookup(var.subnet_cidrs, "Workstations","")) > 0 ? 1 : 0}"
  name                     = "${var.org}-${var.environment}-RdpAccess-SG"
  description              = "External RDP access"
  vpc_id                   = "${module.vpc.vpc_id}"
  tags                     = "${merge(var.default_tags, map("Name", format("%s-%s-RdpAccess-SG", var.org, var.environment)))}"
}

# RDP access from CiDR blocks [optional]
resource "aws_security_group_rule" "allow_rdp_from_cidr" {
  count                    = "${length(lookup(var.subnet_cidrs, "Workstations","")) > 0 ? 1 : 0}"
  type                     = "ingress"
  from_port                = 3389
  to_port                  = 3389
  protocol                 = "TCP"
  cidr_blocks              = ["${var.ssh_cidrs}"] #TECHDEBT really should be a seperate variable from then ssh_cidr
  security_group_id        = "${aws_security_group.rdp_sg.id}"
}

