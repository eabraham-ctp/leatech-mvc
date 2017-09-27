# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Chef - bootstrap
#
# Creates the intial bootstrap Consul service in the PCS VPC. Provisioned with
# chef-solo, rather than the otherwise standard Chef server, since no Chef
# server exists yet.

provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "consul" {
    path = "aws/pcs/chef/tfstate"
  }
}


# # Read the LDAP password from Vault
# provider "vault" {
#   skip_tls_verify = true
# }

# data "vault_generic_secret" "ldap_password" {
#   path = "secret/ctppcs/prod/ldap/bind-password"
# }

# Chef server
module "pcs_chef" {
  source              = "./modules/pcs_chef"
  vpc_id              = "${data.terraform_remote_state.vpc.vpc_id}"
  vpc_cidr            = "${data.terraform_remote_state.vpc.vpc_cidr}"
  subnet_ids          = "${data.terraform_remote_state.vpc.service_subnet_ids.0}"
  ami_id              = "${data.consul_keys.config.var.ami_id}"
  instance_type       = "${data.consul_keys.config.var.instance_type}"
  default_tags        = "${var.default_tags}"
  base_dn             = "#TECHDEBT"
  bind_dn             = "#TECHDEBT"
  bind_secret         = "#TECHDEBT"
  login_attribute     = "#sAMAccountName"
  ldap_host           = "#TECHDEBT"
  ldap_port           = "389"
  org                 = "${var.org}"
  environment         = "${var.environment}"  
  group               = "${data.consul_keys.config.var.group}"
  install_url         = "${data.consul_keys.config.var.install_url}"
  hostname            = "${data.consul_keys.config.var.hostname}"
  admin_username      = "${data.consul_keys.config.var.admin_username}"
  admin_firstname     = "${data.consul_keys.config.var.admin_firstname}"
  admin_lastname      = "${data.consul_keys.config.var.admin_lastname}"
  admin_password      = "${data.consul_keys.config.var.admin_password}"
  email_address       = "${data.consul_keys.config.var.email_address}"
  conn_user_name      = "${data.consul_keys.config.var.conn_user_name}"
  conn_key_name       = "${data.consul_keys.config.var.conn_key_name}"
  conn_private_key    = "${data.consul_keys.config.var.conn_private_key}"
  no_proxy            = "${data.consul_keys.config.var.no_proxy}"
  squid_elb_address   = "${data.terraform_remote_state.squid.squid_elb_address}"
  common_sg           = "${data.terraform_remote_state.vpc.common_sg}"
  ssh_sg              = "${data.terraform_remote_state.vpc.ssh_sg}"
  openvpn_enabled     = "${data.consul_keys.config.var.openvpn_enabled}"
  openvpn_sg          = "${data.consul_keys.config.var.openvpn_sg}"
  vpc_security_group_ids  = ["${list (
                                      data.terraform_remote_state.vpc.ssh_sg,
                                      data.terraform_remote_state.vpc.common_sg
                                    )
                              }"]  
  route53_zone_id     = "${data.consul_keys.config.var.route53_zone_id}"

}
