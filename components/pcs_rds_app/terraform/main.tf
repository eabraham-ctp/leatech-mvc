# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
#
#TECHDEBT

provider "aws" {
  region = "${var.region}"
}

module "rds" {
  source                  = "modules/rds"
  org                     = "${var.org}"
  environment             = "${var.environment}"
  default_tags            = "${var.default_tags}"
  subnet_ids              = ["${data.terraform_remote_state.vpc.data_subnet_ids}"]
  allocated_storage       = "${var.rds_allocated_storage}"
  storage_type            = "gp2"
  engine                  = "postgres"
  instance_type           = "${var.db_instance_type}"
  username                = "${var.db_username}"
  password                = "${var.db_password}"
  multi_az                = "${var.multi_az}"
  general_kms             = "${data.terraform_remote_state.kms.pcs_general_kms}"
  storage_encrypted       = "true"
  db_backups              = "${var.db_backups}"
  db_name                 = "${var.db_name}"
  db_identifier           = "${var.db_identifier}"
  vpc_id                  = "${data.terraform_remote_state.vpc.vpc_id}" 
  app_name                = "rstudio_poc"  #TECHDEBT hardcode to lock the RDS
  app_sg                  = "${module.rstudio.app_sg}",
}

module "rstudio" {
  source                  = "modules/instance"
  vpc_id                  = "${data.terraform_remote_state.vpc.vpc_id}"
  subnet_id               = "${data.terraform_remote_state.vpc.data_subnet_ids[0]}"
  ami_id                  = "${var.rstudio_ami_id}" 
  instance_type           = "${var.rstudio_instance_type}"
  conn_key_name           = "${var.conn_key_name}" #TECHDEBT should be from the backend
  conn_user_key           = "${var.conn_user_key}" #TECHDEBT should be from the backend
  default_tags            = "${var.default_tags}"
  no_proxy                = "${var.no_proxy}"
  squid_elb_address       = "${data.terraform_remote_state.squid.squid_elb_address}"
  squid_elb_sg            = "${data.terraform_remote_state.squid.squid_elb_sg}"
  org                     = "${var.org}"
  environment             = "${var.environment}"
  app_name                = "Rstudio"  #TECHDEBT hardcode to lock the RDS
  rds_port                = "5432"
  rds_sg                  = "sg-59135f21" #TECHDEBT hardcode to lock the RDS
  squid_elb_address       = "${data.terraform_remote_state.squid.squid_elb_address}"
  sg_map                  = "${var.rstudio_map}"
  workstation_sg          = "${var.workstation_sg}"
  iam_instance_profile    = "${var.iam_instance_profile}"
  vpc_security_group_ids  = ["${list (
                                      data.terraform_remote_state.vpc.ssh_sg,
                                      data.terraform_remote_state.vpc.common_sg
                                    )
                              }"]
}
