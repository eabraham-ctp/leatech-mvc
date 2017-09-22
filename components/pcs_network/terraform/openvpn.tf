# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# OpenVPN (simple)
#

# VPN connection to the VPC, this is not relevent to the VPC but IS required for routing #TECHDEBT

module "openvpn" {
  source                 = "modules/openvpn"
  default_tags           = "${var.default_tags}"
  environment            = "${var.environment}"
  org                    = "${var.org}"
  openvpn_user           = "${var.openvpn_user}"
  openvpn_password       = "${var.openvpn_password}"
  openvpn_ami            = "${var.openvpn_ami}"
  openvpn_eip            = "${var.openvpn_eip}"
  vpc_id                 = "${module.vpc.vpc_id}"
  dmz_subnet_ids         = "${module.dmz_subnets.subnet_ids}"
  vpc_cidr               = "${var.vpc_cidr}"
  conn_key_name          = "${var.conn_key_name}"
  vpc_security_group_ids = ["${list (
                                      aws_security_group.ssh_sg.id,
                                      aws_security_group.common_services_group.id,
                                      aws_security_group.security_services_group.id
                                     )
                              }"]  
}