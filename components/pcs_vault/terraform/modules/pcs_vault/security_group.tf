# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Vault
#
# Creates a Vault server for Platform Common Services (PCS).

# Security Group name format
# <Org/BU>-<Application Name>-<Environment>-<Tier>

resource "aws_security_group" "vault" {
  name        = "${var.org}-${var.environment}-Vault-App-SG"
  description = "Vault internal traffic, administration, and UI"
  vpc_id      = "${var.vpc_id}"
  tags        = "${merge(var.default_tags, map("Name", format("%s-%s-Vault-SG", var.org, var.environment)))}"
}


###############################################
# Egress - Global
###############################################

resource "aws_security_group_rule" "egress_consul" {
  type                      = "egress"
  from_port                 = 8500
  to_port                   = 8500
  protocol                  = "tcp"
  source_security_group_id  = "${var.consul_cluster_sg_id}"
  security_group_id         = "${aws_security_group.vault.id}"
}

###############################################
# Ingress - Global
###############################################

# For standard API requests internal requests
resource "aws_security_group_rule" "api_ingress" {
  type                     = "ingress"
  from_port                = 8200
  to_port                  = 8200
  protocol                 = "tcp"
  cidr_blocks              = ["${var.vpc_cidr}"]
  security_group_id        = "${aws_security_group.vault.id}"
}

# For standard API requests via OpenVPN
resource "aws_security_group_rule" "api_ingress_via_vpn" {
  type                     = "ingress"
  from_port                = 8200
  to_port                  = 8200
  protocol                 = "tcp"
  source_security_group_id = "${var.openvpn_sg}" # SSH access from Open VPN clients
  security_group_id        = "${aws_security_group.vault.id}"
}

# For internal traffic between cluster members
resource "aws_security_group_rule" "self_tcp_8201" {
  type                     = "ingress"
  from_port                = 8201
  to_port                  = 8201
  protocol                 = "tcp"
  self                     = true
  security_group_id        = "${aws_security_group.vault.id}"
}
