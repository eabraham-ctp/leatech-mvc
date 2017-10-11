# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
#
#TECHDEBT

provider "aws" {
  region = "${var.region}"
}

module "pcs_ami_kms" {
  source              = "modules/pcs_kms"
  default_tags        = "${var.default_tags}"
  environment         = "${var.environment}"
  org                 = "${var.org}"
  region              = "${var.region}"
  kms_name            = "AMIEncrypt-key"
  kms_description     = "AMI encryption key"
}

module "pcs_general_kms" {
  source              = "modules/pcs_kms"
  default_tags        = "${var.default_tags}"
  environment         = "${var.environment}"
  org                 = "${var.org}"
  region              = "${var.region}"  
  kms_name            = "GeneralEncrypt-key"
  kms_description     = "General encryption key for all things not AMI"

}

module "pcs_cloudtrail_kms" {
  source              = "modules/pcs_kms"
  default_tags        = "${var.default_tags}"
  environment         = "${var.environment}"
  org                 = "${var.org}"
  region              = "${var.region}"  
  kms_name            = "CloudTrailEncrypt-key"
  kms_description     = "CloudTrail encryption key"

}