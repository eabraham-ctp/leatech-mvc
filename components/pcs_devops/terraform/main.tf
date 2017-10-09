# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# devops - bootstrap
#

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

data "terraform_remote_state" "vault" {
  backend = "consul"
  environment = "${terraform.env}"
  config {
    path = "aws/pcs/vault/tfstate"
  }
}

module "devops" {
  source                = "modules/pcs_devops"
  vpc_id                = "${data.terraform_remote_state.vpc.vpc_id}"
  default_tags          = "${var.default_tags}"
  consul_sg_ids         = ["${data.terraform_remote_state.consul.consul_cluster_sg_id}"]
  vault_sg_ids          = ["${data.terraform_remote_state.vault.vault_sg_id}"]
  ssh_sg_ids            = ["${data.terraform_remote_state.vpc.ssh_sg}"]
  region                = "${var.region}"   
  org                   = "${var.org}"
  environment           = "${var.environment}"
  s3_endpoint_prefix_id = "${data.terraform_remote_state.vpc.s3_endpoint_prefix_id}"   
}
