provider "aws" {
  region = "${var.region}"
}


resource "aws_instance" "app" {
  ami                    = "${var.ami_id}"
  instance_type          = "${var.instance_type}"
  iam_instance_profile   = "${var.iam_instance_profile}"
  key_name               = "${var.conn_key_name}"
  vpc_security_group_ids = ["${concat(
                                    list(aws_security_group.app_sg.id),
                                    var.vpc_security_group_ids
                                  )
                             }"]
  subnet_id              = "${var.subnet_id}"
  tags                   = "${merge(var.default_tags, map("Name", format("%s-%s-%s-EC2", var.org, var.environment, var.app_name)))}"
}
