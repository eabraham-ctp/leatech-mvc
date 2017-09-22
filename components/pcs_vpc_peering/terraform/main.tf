# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
#
#TECHDEBT

provider "aws" {
  region = "${var.region}"
}

module "pcs_vpc_peering" {
  source              = "modules/pcs_vpc_peering"
  default_tags        = "${var.default_tags}"
  environment         = "${var.environment}"
  org                 = "${var.org}"
  region              = "${var.region}"
  # peer_acct_id        = "${var.vpcpeer_accepter_acct_id}"
  peer_acct_profile   = "${var.vpcpeer_accepter_profile}"
  peer_acct_cidr      = "${var.vpcpeer_accepter_vpc_cidr}"
  peer_vpc_id         = "${var.peer_vpc_id}"
  vpc_id              = "${var.vpc_id}"
  requester_profile   = "${var.aws_profile}"
}