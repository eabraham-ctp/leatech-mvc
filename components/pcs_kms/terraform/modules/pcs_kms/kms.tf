# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# One time resources for Bootstrap Process
# Encrypted AMI
# Creates a KMS Key to encrypt EBS volumes used during the bootstrap process.

# This data source allows us to access the AWS region

data "template_file" "kms_key_policy" {
  template = "${file("${path.module}/kms_policy.tpl")}"
  vars {
    accountno = "${data.aws_caller_identity.current.account_id}"
    keyadmin  = "${data.aws_caller_identity.current.arn}"
    keyusers  = "${data.aws_caller_identity.current.arn}"
  }
}

resource "aws_kms_key" "ami_key" {
  description             = "${var.kms_description}"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  policy                  = "${data.template_file.kms_key_policy.rendered}"
  tags                    = "${merge(var.default_tags, map("Name", format("%s-%s-%s", var.org, var.environment, var.kms_name)))}"
}

resource "aws_kms_alias" "ami_key_alias" {
  name          = "alias/${var.org}-${var.environment}-${var.kms_name}"
  target_key_id = "${aws_kms_key.ami_key.key_id}"
}
