# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Splunk - bootstrap
#
# Creates the intial bootstrap Splunk service in the PCS VPC.


module "s3" {
  source = "./modules/s3"
  app = "${lookup(var.default_tags, "ApplicationName", "Cloudtrail")}"
  group = "${lookup(var.default_tags, "Group", "PSS")}"
  org = "${var.org}"
  environment = "${var.environment}"
  default_tags = "${var.default_tags}"
  kms_key = "${var.kms_key}"
  ct_account_numbers = "${var.ct_account_numbers}"
  ct_accounts = "${var.ct_accounts}"
  ct_account_name = "${var.ct_account_name}"
  ct_trails = "${var.ct_trails}"
  force_destroy = "true"
  versioning = "true"
}

module "trail" {
  source              = "./modules/trail"
  cl_role_arn         = "${module.s3.cl_role_arn}"
  cl_log_group_arn    = "${module.s3.cl_log_group_arn}"
  bucket              = "${module.s3.bucket}"
  bucket_prefix       = "${var.ct_account_name}"
  sns_topic_name      = "${module.s3.sns_topic_name}"
  kms_key             =  "${var.kms_key}"
  app                 = "${lookup(var.default_tags, "ApplicationName", "Cloudtrail")}"
  group               = "${lookup(var.default_tags, "Group", "PSS")}"
  org                 = "${var.org}"
  environment         = "${var.environment}"
  default_tags        = "${var.default_tags}"
}




