# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Splunk - bootstrap
#
# Creates the intial bootstrap Splunk service in the PCS VPC.

# Configure Cloudtrail
module "cloudtrail" {
  source = "./modules/cloudtrail"
  app                 = "${lookup(var.default_tags, "ApplicationName", "Cloudtrail")}"
  group               = "${lookup(var.default_tags, "Group", "PCS")}"
  org                 = "${var.org}"
  environment         = "${var.environment}"
  default_tags        = "${var.default_tags}"
}

# Splunk cluster
module "splunk" {
  source              = "./modules/splunk"
  vpc_id              = "${data.terraform_remote_state.vpc.vpc_id}"
  availability_zones  = "${join(",", data.terraform_remote_state.vpc.azs)}"
  subnets             = "${join(",", data.terraform_remote_state.vpc.service_subnet_ids)}"
  ssh_sg              = "${data.terraform_remote_state.vpc.ssh_sg}"
  common_sg           = "${data.terraform_remote_state.vpc.common_sg}"
  squid_elb_sg        = ""
  openvpn_sg          = "${data.terraform_remote_state.vpc.openvpn_sg}"
  vpc_security_group_ids  = ["${list(data.terraform_remote_state.vpc.ssh_sg)}"]
  vpc_cidr            = "${data.terraform_remote_state.vpc.vpc_cidr}"
  
  instance_user       = "${data.consul_keys.config.var.conn_user_name}"
  key_name            = "${data.consul_keys.config.var.conn_key_name}"
  ami                 = "${var.ami}"
  deploymentserver_ip = "${var.deploymentserver_ip}"
  elb_internal        = "${var.elb_internal}"
  instance_type       = "${var.instance_type}"
  searchhead_count    = "${var.searchhead_count}"
  indexer_count       = "${var.indexer_count}"

  indexer_volume_size = "${var.indexer_volume_size}"
  pass4SymmKey        = "${var.pass4SymmKey}"
  secret              = "${var.secret}"
  ui_password         = "${var.ui_password}"
  replication_factor  = "${var.indexer_count}"
  search_factor       = "${var.searchhead_count}"
  sqs_queue           = "${module.cloudtrail.aws_sqs_queue_arn}"

  app                 = "${lookup(var.default_tags, "ApplicationName", "Splunk")}"
  group               = "${lookup(var.default_tags, "Group", "PCS")}"
  org                 = "${var.org}"
  environment         = "${var.environment}"
  default_tags        = "${var.default_tags}"
}

