# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Route53 - bootstrap
#
# Creates the intial bootstrap Route53 service in the PCS VPC.

provider "aws" {
  region = "${var.region}"
}

module "route53zone" {
  source       = "./modules/private-zone"
  fqdn         = "${var.group}-${var.environment}.${element(split("-",var.org),0)}.internal"
  default_tags = "${var.default_tags}"
  vpc_id       = "${var.vpc_id}"
  region       = "${var.region}"
  org          = "${element(split("-",var.org),0)}"
  environment  = "${var.environment}"
  group        = "${var.group}"
}
