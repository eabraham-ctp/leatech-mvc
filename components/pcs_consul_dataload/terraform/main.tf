# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Consul Dataload - bootstrap
#
# Loads the configuraiton paramters in to Consul
#

# Add common keys to Consul
resource "consul_key_prefix" "config" {
  # Prefix to add to prepend to all of the subkey names below.
  #TECHDEBT this structure needs work some of these items will be shared suggest more granularity based on region
  path_prefix             = "aws/pcs/config/${var.org}/${var.environment}/"
  subkeys = {
    "os/ami_id"           = "${var.ami_id}"
    "os/type"             = "${var.os}"   
    "os/conn/user_name"   = "ec2-user"
    "os/conn/key_name"    = "${var.conn_key_name}"
    "os/conn/key_file"    = "${var.conn_private_key}"
    "region"              = "${var.region}"
    "org"                 = "${var.org}"
    "environment"         = "${var.environment}"
    "group"               = "${element(split("-", var.org),1)}" #TECHDEBT group should be correct
    "default_tags"        = "${jsonencode(var.default_tags)}"
    "squid_elb_address"   = "${data.terraform_remote_state.squid.squid_elb_address}"
    "openvpn/enabled"     = "${length(var.openvpn_sg) > 0 ? "true" : "false"}"
    "openvpn/openvpn_sg"  = "${var.openvpn_sg}"
    "kms/ami_key_arn"     = "${data.terraform_remote_state.kms.pcs_ami_kms}"
    "kms/general_key_arn" = "${data.terraform_remote_state.kms.pcs_general_kms}"
    "private_domain"      = "${length(var.private_domain) > 0 ? var.private_domain : data.terraform_remote_state.route53.private_domain}"
    "route53_zone_id"     = "${data.terraform_remote_state.route53.zone_id}"
  }
} 
