# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Consul - bootstrap
#
# Creates the intial bootstrap Consul service in the PCS VPC. Provisioned with
# chef-solo, rather than the otherwise standard Chef server, since no Chef
# server exists yet.

provider "aws" {
  region              = "${var.region}"
}

# Consul server
module "pcs_consul" {
  source              = "modules/pcs_consul"
  vpc_name            = "${var.vpc_name}" #TECHDEBT why?
  vpc_id              = "${var.vpc_id}"
  default_tags        = "${var.default_tags}"
  ami_id              = "${var.ami_id}"
  os                  = "${var.os}"
  conn_key_name       = "${var.conn_key_name}"
  conn_user_key       = "${var.conn_user_key}"
  conn_private_key    = "${var.conn_private_key}"
  subnet_ids          = "${var.service_subnet_ids}"
  bootstrap           = true
  chef_key            = "${path.module}/chef_key"
  instance_type       = "m4.large"
  squid_elb_address   = "${var.squid_elb_address}"
  vpc_security_group_ids  = ["${list (
                                      var.ssh_sg,
                                      var.common_sg,
                                      var.sec_service_sg
                                    )
                              }"]  
  vpc_cidr            = "${var.vpc_cidr}"
  ssh_sg              = "${var.ssh_sg}"
  sec_service_sg      = "${var.sec_service_sg}"  
  no_proxy            = "${var.no_proxy}"
  environment         = "${var.environment}"
  org                 = "${var.org}"
  route53_zone_id     = "${var.route53_zone_id}"
}
