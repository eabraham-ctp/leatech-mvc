# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
#
#TECHDEBT

provider "aws" {
  region = "${var.region}"
}


module "talend" {
  source                  = "modules/instance"
  vpc_id                  = "${data.terraform_remote_state.vpc.vpc_id}"
  subnet_id               = "${data.terraform_remote_state.vpc.data_subnet_ids[0]}"
  ami_id                  = "${var.talend_ami_id}" 
  iam_instance_profile    = "${var.talend_iam_instance_profile}" 

  instance_type           = "${var.talend_instance_type}"
  conn_key_name           = "${var.conn_key_name}" #TECHDEBT should be from the backend
  conn_user_key           = "${var.conn_user_key}" #TECHDEBT should be from the backend
  default_tags            = "${var.default_tags}"
  no_proxy                = "${var.no_proxy}"
  squid_elb_address       = "${data.terraform_remote_state.squid.squid_elb_address}"
  squid_elb_sg            = "${data.terraform_remote_state.squid.squid_elb_sg}"
  org                     = "${var.org}"
  environment             = "${var.environment}"
  app_name                = "Talend"
  rds_port                = "${data.terraform_remote_state.rdsapp.rds_port}"
  rds_sg                  = "${data.terraform_remote_state.rdsapp.rds_sg}"
  squid_elb_address       = "${data.terraform_remote_state.squid.squid_elb_address}"
  sg_map                  = "${var.talend_map}"
  workstation_sg          = "${var.workstation_sg}"
  vpc_security_group_ids  = ["${list (
                                      data.terraform_remote_state.vpc.rdp_sg,
                                      data.terraform_remote_state.vpc.common_sg
                                    )
                              }"]
  s3_endpoint_prefix_id   = "${data.terraform_remote_state.vpc.s3_endpoint_prefix_id}"               
}
