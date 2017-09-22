# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Jenkins
#
# Module for creating the Jenkins Service for Platform Common Services (PCS). This version uses
# Chef cookbooks on top of the Terraform scripts

resource "aws_security_group" "jenkins_master_elb" {
  name        = "${var.org}-JenkinsMasterELB-${var.environment}-App"
  vpc_id      = "${var.vpc_id}"
  description = "Jenkins Master ELB security group"

tags = "${merge(var.default_tags, map("Name", format("%s-JenkinsMasterELB-%s-App", var.org, var.environment)))}"

  ingress {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  ingress {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  egress {
    protocol  = -1
    from_port = 0
    to_port   = 0

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

}

resource "aws_security_group" "jenkins_master" {
  name        = "${var.org}-JenkinsMaster-${var.environment}-App"
  vpc_id      = "${var.vpc_id}"
  description = "Jenkins Master security group"

  tags = "${merge(var.default_tags, map("Name", format("%s-JenkinsMaster-%s-App", var.org, var.environment)))}"

  egress {
    protocol  = -1
    from_port = 0
    to_port   = 0

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

resource "aws_security_group_rule" "jenkins_master_ingress_corp_ssh" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = [
    "${var.allowed_ips}"]
  security_group_id = "${aws_security_group.jenkins_master.id}"

  depends_on = [
    "aws_security_group.jenkins_master"
  ]

  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_security_group" "jenkins_slave" {
  name        = "${var.org}-JenkinsSlave-${var.environment}-App"

  vpc_id      = "${var.vpc_id}"
  description = "Jenkins Slave security group"

  tags = "${merge(var.default_tags, map("Name", format("%s-JenkinsSlave-%s-App", var.org, var.environment)))}"

  ingress {
    protocol  = -1
    from_port = 0
    to_port   = 0

    security_groups = [
      "${aws_security_group.jenkins_master.id}",
    ]
  }

  egress {
    protocol  = -1
    from_port = 0
    to_port   = 0

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

resource "aws_security_group_rule" "jenkins_slave_ingress_corp_ssh" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = [
    "${var.allowed_ips}"]
  security_group_id = "${aws_security_group.jenkins_slave.id}"

  depends_on = [
    "aws_security_group.jenkins_master"
  ]

  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_security_group_rule" "jenkins_master_elb_access_https" {
  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  security_group_id        = "${aws_security_group.jenkins_master.id}"
  source_security_group_id = "${aws_security_group.jenkins_master_elb.id}"

  depends_on = [
    "aws_security_group.jenkins_master",
    "aws_security_group.jenkins_master_elb"
  ]

  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_security_group_rule" "jenkins_master_elb_access_http" {
  type      = "ingress"
  from_port = 8080
  to_port   = 8080
  protocol  = "tcp"

  security_group_id = "${aws_security_group.jenkins_master.id}"
  source_security_group_id = "${aws_security_group.jenkins_master_elb.id}"

  depends_on = [
    "aws_security_group.jenkins_master",
    "aws_security_group.jenkins_master_elb"
  ]

  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_security_group_rule" "master_slave_access" {
  type      = "ingress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"

  security_group_id        = "${aws_security_group.jenkins_master.id}"
  source_security_group_id = "${aws_security_group.jenkins_slave.id}"

  depends_on = [
    "aws_security_group.jenkins_master",
    "aws_security_group.jenkins_slave"
  ]

  lifecycle {
    create_before_destroy = false
  }
}

# resource "aws_security_group_rule" "jenkins_client_access" {
#   type      = "ingress"
#   from_port = 0
#   to_port   = 65535
#   protocol  = "tcp"
#
#   security_group_id        = "${var.css_sg_id}"
#   source_security_group_id = "${aws_security_group.jenkins_master.id}"
#
#   lifecycle {
#     create_before_destroy = false
#   }
# }

resource "aws_iam_instance_profile" "jenkins" {
  name = "${var.org}-Jenkins-${var.environment}"

  role = "${aws_iam_role.jenkins.name}"

  depends_on = [
    "aws_iam_role.jenkins"]
}

resource "aws_iam_role" "jenkins" {
  name = "${var.org}-Jenkins-Service-Int-${var.environment}"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "jenkins" {
  name   = "${var.org}-Jenkins-${var.environment}"
  role   = "${aws_iam_role.jenkins.id}"
  policy = "${file("${path.module}/iam_policy.json")}"

  depends_on = [
    "aws_iam_instance_profile.jenkins"]
}

resource "aws_elb" "jenkins_master" {
  name = "${var.org}-JenkinsMasterELB-Int"
  internal = true
  idle_timeout              = 400
  cross_zone_load_balancing = true
  connection_draining       = true

  subnets = ["${var.subnet_ids}"]

  security_groups = [
    "${aws_security_group.jenkins_master_elb.id}"]

  instances = [
    "${aws_instance.master.id}"
  ]

#  access_logs {
#    bucket        = "${aws_s3_bucket.elb_access_log.bucket}"
#    bucket_prefix = "${aws_s3_bucket_object.elb_access_log_prefix.key}"
#    interval      = 5
#  }

  listener {
    instance_port = 8080
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  listener {
    instance_port = 443
    instance_protocol = "tcp"
    lb_port = 443
    lb_protocol = "tcp"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:8080/login"
    interval = 30
  }

  tags = "${merge(var.default_tags, map("Name", format("%s-JenkinsELB-Int-%s", var.org, var.environment)))}"

  depends_on = [
    "aws_security_group.jenkins_master_elb"
  ]

  lifecycle {
    create_before_destroy = false
  }
}

# Chef JSON attributes for configuring Active Directory authentication
data "template_file" "chef_attributes" {
  template = "${file(format("%s/chef_attributes.json.tpl", path.module))}"
  vars {
    domain_name = "${var.ad_domain}"
    domain_servers = "${join(",", formatlist("%s:3268", var.ad_servers))}"
  }
}

resource "aws_instance" "master" {

  instance_type        = "${var.instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.jenkins.id}"
  ami                  = "${var.ami_id}"
  key_name             = "${var.conn_key_name}"
  subnet_id            = "${var.subnet_ids[count.index]}"

  connection {
    # The default username for our AMI
    type        = "ssh"
    user        = "${var.conn_user_name}"
    private_key = "${file(var.conn_user_key)}"
  }

  vpc_security_group_ids = [
    "${aws_security_group.jenkins_master.id}",
  ]

  depends_on = [
    "aws_security_group.jenkins_master",
    "aws_iam_role_policy.jenkins",
    "aws_security_group_rule.jenkins_master_ingress_corp_ssh"]

  tags = "${merge(var.default_tags, map("Name", format("%s-JenkinsMaster-%s-App", var.org, var.environment)))}"

  provisioner "chef" {
    run_list                = ["pcs_jenkins::default"]
    attributes_json         = "${data.template_file.chef_attributes.rendered}"
    node_name               = "${var.node_name}"
    server_url              = "${var.chef_server_url}"
    fetch_chef_certificates = true
    recreate_client         = true
    user_name               = "${var.chef_user_name}"
    user_key                = "${file(var.chef_user_key)}"
    # version                 = "${var.version}"
  }

}
