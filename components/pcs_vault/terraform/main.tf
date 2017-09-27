# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Vault - bootstrap
#
# Creates the intial bootstrap Vault service in the PCS VPC. Provisioned with
# chef-solo, rather than the otherwise standard Chef server, since no Chef
# server exists yet.

provider "aws" {
  region = "${var.region}"
}

data "terraform_remote_state" "vpc" {
  backend     = "consul"
  environment = "${terraform.env}"
  config {
    path = "aws/pcs/vpc/tfstate"
  }
}

data "terraform_remote_state" "consul" {
  backend = "consul"
  environment = "${terraform.env}"
  config {
    path = "aws/pcs/consul/tfstate"
  }
}

data "terraform_remote_state" "squid" {
  backend     = "consul"
  environment = "${terraform.env}"
  config {
    path = "aws/pcs/squid/tfstate"
  }
}


data "terraform_remote_state" "route53" {
  backend     = "consul"
  environment = "${terraform.env}"
  config {
    path = "aws/pcs/route53/tfstate"
  }
}   


# Vault server     

module "vault" {
  source               = "modules/pcs_vault"
  vpc_name             = "${data.terraform_remote_state.vpc.vpc_name}"
  vpc_id               = "${data.terraform_remote_state.vpc.vpc_id}"
  vpc_cidr             = "${data.terraform_remote_state.vpc.vpc_cidr}"
  subnet_id            = "${data.terraform_remote_state.vpc.service_subnet_ids[0]}"
  ami_id               = "${var.ami_id}" #TECHDEBT should be from the backend
  consul_address       = "${data.terraform_remote_state.consul.consul_address}"
  consul_data_center   = "${data.terraform_remote_state.consul.consul_data_center}"
  consul_agent_sg_id   = "${data.terraform_remote_state.consul.consul_agent_sg_id}"
  consul_cluster_sg_id = "${data.terraform_remote_state.consul.consul_cluster_sg_id}"
  cluster_name         = "${var.cluster_name}" #TECHDEBT not used
  ssh_cidrs            = "${var.ssh_cidrs}" 
  conn_key_name        = "${var.conn_key_name}" #TECHDEBT should be from the backend
  conn_user_key        = "${var.conn_user_key}" #TECHDEBT should be from the backend
  os                   = "${var.os}"
  default_tags         = "${var.default_tags}"
  no_proxy             = "${var.no_proxy}"
  squid_elb_address    = "${data.terraform_remote_state.squid.squid_elb_address}"
  squid_elb_sg         = "${data.terraform_remote_state.squid.squid_elb_sg}"
  openvpn_sg           = "${data.terraform_remote_state.vpc.openvpn_sg}"
  common_sg            = "${data.terraform_remote_state.vpc.common_sg}"
  ssh_sg               = "${data.terraform_remote_state.vpc.ssh_sg}"
  vpc_security_group_ids  = ["${list (
                                      data.terraform_remote_state.vpc.ssh_sg,
                                      data.terraform_remote_state.vpc.common_sg,
                                      data.terraform_remote_state.vpc.sec_service_sg
                                    )
                              }"]  
  org                  = "${var.org}"
  environment          = "${var.environment}"
  common_sg            = "${data.terraform_remote_state.vpc.common_sg}"
  route53_zone_id      = "${data.terraform_remote_state.route53.zone_id}"

}
