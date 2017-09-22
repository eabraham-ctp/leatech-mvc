provider "consul" {

}

provider "aws" {
  region = "${var.region}"
}

#TECHDEBT - need to implement this for passwords and usernames

#provider "vault" {
#  address = "${data.terraform_remote_state.vault.vault_url}"
#
#}

module "trend-micro-dsm" {
  source                  = "./modules/trend_dsm_server"
  vpc_id                  = "${data.terraform_remote_state.vpc.vpc_id}"

  security_subnet_ids     = "${data.terraform_remote_state.vpc.security_subnet_ids}"

  data_subnet_ids         = "${data.terraform_remote_state.vpc.data_subnet_ids}"
  
  instance_type           = "${var.tm_instance_type}"

#TECHDEBT - the KMS formatting messes up the variable when stored in consul.  
# Need a better way to to do this between accounts
  general_kms             = "${var.kms_general_key}"
  
  conn_key_name           = "${data.consul_keys.config.var.conn_key_name}"

  region                  = "${var.region}"

  default_tags            = "${var.default_tags}" //"${data.consul_keys.config.var.default_tags}"
  
  org                     = "${element(split("-",var.org),0)}"
  environment             = "${var.environment}"
  group                   = "${var.group}"
  vpc_cidr                = "${data.terraform_remote_state.vpc.vpc_cidr}"
  zone_id                 = "${data.terraform_remote_state.route53.zone_id}"

  #####
  # ELB Configuration
  #####
  elb_healthy_threshold         = "${var.elb_healthy_threshold}"
  elb_unhealthy_threshold       = "${var.elb_unhealthy_threshold}"
  elb_timeout                   = "${var.elb_timeout}"
  elb_health_check_interval     = "${var.elb_health_check_interval}"
  elb_health_check_target       = "${var.health_check_target}"
  
  #####
  # Security Group Configuration
  #####
  common_sg               = "${data.terraform_remote_state.vpc.common_sg}"
  squid_elb_sg            = "${data.terraform_remote_state.squid.squid_elb_sg}"
  openvpn_sg              = "${data.terraform_remote_state.vpc.openvpn_sg}"
  vpc_security_group_ids  = ["${list (
                                      data.terraform_remote_state.vpc.ssh_sg,
                                      data.terraform_remote_state.vpc.common_sg,
                                      data.terraform_remote_state.vpc.sec_service_sg
                                    )
                              }"]

  tm_ami_id               = "${var.tm_ami_id}"

  dsm_db_engine           = "${var.dsm_db_engine}"
  dsm_db_type             = "${var.dsm_db_type}"
  dsm_db_instance_type    = "${var.dsm_db_instance_type}"
  dsm_db_instance_name    = "${var.dsm_db_instance_name}"
  
#TECHDEBT - this should be in vault.
  dsm_db_username         = "${var.dsm_db_username}"
  dsm_db_password         = "${var.dsm_db_password }"

#TECHDEBT - this should be in vault.
  dsm_username            = "${var.dsm_username}"
  dsm_password            = "${var.dsm_password}"

  dsm_managerport         = "${var.dsm_managerport}"
  dsm_heartbeatport       = "${var.dsm_heartbeatport}"

  squid_elb_address       = "${data.terraform_remote_state.squid.squid_elb_address}"
  
}

output "dsm_elb_url" {
    value = "${module.trend-micro-dsm.dsm_elb_url}"
}

output "trend_fqdn" { 
    value = "${module.trend-micro-dsm.trend_fqdn}"
}
