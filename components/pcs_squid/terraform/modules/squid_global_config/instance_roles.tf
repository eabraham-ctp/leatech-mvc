data "template_file" "squid_policy_template" {
  template              = "${file("${path.module}/squid_instance_profile_policy.tpl")}"
  vars {
    backend_bucket_name = "${var.backend_bucket_name}",
    squid_conf_prefix   = "${var.squid_conf_prefix}"
  }
}

resource "aws_iam_instance_profile" "squid_instance_profile" {
  name_prefix           = "${element(split("-", var.org),0)}-${upper(var.environment)}-SquidInstance-profile"
  role                  = "${aws_iam_role.squid_role.name}"
  depends_on            = ["aws_iam_role.squid_role"]
}

resource "aws_iam_role" "squid_role" {
  name_prefix           = "${element(split("-", var.org),0)}-SquidAccess-service-role"  
  assume_role_policy    = "${file("${path.module}/ec2_assume_role_policy.json")}"
}

resource "aws_iam_role_policy" "squid_policy" {
  name_prefix           = "${element(split("-", var.org),0)}-SquidS3BucketAccess-policy"  
  role                  = "${aws_iam_role.squid_role.id}"
  policy                = "${data.template_file.squid_policy_template.rendered}"
  depends_on            = ["aws_iam_role.squid_role"]
}