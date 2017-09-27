provider "aws" {
  region     = "${var.region}"
}

module "squid_global_config" {
  source                          = "./modules/squid_global_config"
  environment                     = "${var.environment}"
  org                             = "${var.org}"  
  region                          = "${var.region}"
  squid_conf_prefix               = "${var.squid_conf_prefix}"
  backend_bucket_name             = "${var.backend_bucket_name}"
  default_tags                    = "${var.default_tags}"
}

module "squid_instance_config" {
  source                          = "./modules/squid_instance_config" 
  environment                     = "${var.environment}"
  region                          = "${var.region}"
  org                             = "${var.org}"
  squid_port                      = "${var.squid_port}"
  sq_elb_source_cidrs             = "${var.vpc_cidr}"
  ec2_squid_instance_type         = "${var.ec2_squid_instance_type}"
  ami_id                          = "${var.ami_id}"
  conn_key_name                   = "${var.conn_key_name}"
  vpc_cidr                        = "${var.vpc_cidr}"
  vpc_id                          = "${var.vpc_id}"
  subnet_ids                      = "${var.dmz_subnet_ids}"
  default_tags                    = "${var.default_tags}"
  backend_bucket_name             = "${var.backend_bucket_name}"
  squid_conf_prefix               = "${var.squid_conf_prefix}"
  squid_instance_profile          = "${module.squid_global_config.squid_instance_profile}"
  common_sg                       = "${var.common_sg}"
  vpc_security_group_ids          = ["${list (
                                      var.ssh_sg,
                                      var.common_sg
                                    )}"]  
  squid_egress_ports              = "${var.squid_egress_ports}"
  route53_zone_id                 = "${var.route53_zone_id}"
}
