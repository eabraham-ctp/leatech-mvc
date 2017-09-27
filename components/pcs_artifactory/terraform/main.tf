# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# artifactory
#
# Creates a artifactory server (or cluster) for Platform Common Services (PCS).


provider "aws" {
  region = "${var.region}"
}


module "pcs_artifactory" {
  source              = "./modules/pcs_artifactory"
  vpc_id              = "${data.terraform_remote_state.vpc.vpc_id}"
  vpc_cidr            = "${data.terraform_remote_state.vpc.vpc_cidr}"
  subnet_ids          = "${data.terraform_remote_state.vpc.service_subnet_ids.0}"
  ami_id              = "${data.consul_keys.config.var.ami_id}"
  instance_type       = "${data.consul_keys.config.var.instance_type}"
  default_tags        = "${var.default_tags}"
  org                 = "${var.org}"
  environment         = "${var.environment}"  
  group               = "${data.consul_keys.config.var.group}"
  conn_user_name      = "${data.consul_keys.config.var.conn_user_name}"
  conn_key_name       = "${data.consul_keys.config.var.conn_key_name}"
  conn_private_key    = "${data.consul_keys.config.var.conn_private_key}"
  no_proxy            = "${data.consul_keys.config.var.no_proxy}"
  squid_elb_address   = "${data.terraform_remote_state.squid.squid_elb_address}"
  common_sg           = "${data.terraform_remote_state.vpc.common_sg}"
  ssh_sg              = "${data.terraform_remote_state.vpc.ssh_sg}"
  vpc_security_group_ids  = ["${list (
                                      data.terraform_remote_state.vpc.ssh_sg,
                                      data.terraform_remote_state.vpc.common_sg
                                    )
                              }"]
  chef_server_url     = "${lower(format("https://%s/organizations/%s-%s",data.terraform_remote_state.chef.chef_elb_address,var.org,var.environment))}"
  http_proxy          = "${format("http://%s",data.terraform_remote_state.squid.squid_elb_address)}"
  https_proxy         = "${format("http://%s",data.terraform_remote_state.squid.squid_elb_address)}"
  no_proxy            = "${data.consul_keys.config.var.no_proxy}${",trend.pcs-sbx.vmdb.internal"}"
  route53_zone_id     = "${data.consul_keys.config.var.route53_zone_id}"
  private_domain      = "${data.consul_keys.config.var.private_domain}"
  chef_user_name      = "${data.terraform_remote_state.chef.admin_username}"
  chef_user_key       = "${data.terraform_remote_state.chef.admin_key}"
  bootstrap           = "${var.bootstrap}"
}
