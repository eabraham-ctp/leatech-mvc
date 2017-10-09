# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Jenkins
#
# Module for creating the Jenkins Service for Platform Common Services (PCS). This version uses
# Chef cookbooks on top of the Terraform scripts

resource "aws_security_group" "jenkins_master_elb_sg" {
  name        = "${var.org}-${var.environment}-JenkinsMasterELB-SG"
  vpc_id      = "${var.vpc_id}"
  description = "Jenkins Master ELB security group"

tags = "${merge(var.default_tags, map("Name", format("%s-%s-JenkinsMasterELB-SG", var.org, var.environment)))}"

}

resource "aws_security_group" "jenkins_master_sg" {
  name        = "${var.org}-${var.environment}-JenkinsMaster-SG"
  vpc_id      = "${var.vpc_id}"
  description = "Jenkins Master security group"

  tags = "${merge(var.default_tags, map("Name", format("%s-%s-JenkinsMaster-SG", var.org, var.environment)))}"
}

resource "aws_security_group" "jenkins_slave" {
  name                       = "${var.org}-${var.environment}-JenkinsSlave-SG"
  vpc_id                     = "${var.vpc_id}"
  description                = "Jenkins Slave security group"
  tags                       = "${merge(var.default_tags, map("Name", format("%s-%s-JenkinsSlave-SG", var.org, var.environment)))}"
  ingress {
    from_port                = 22
    to_port                  = 22
    protocol                 = "TCP"

    security_groups          = [
                                  "${aws_security_group.jenkins_master_sg.id}",
                                ]
    }
}

resource "aws_security_group_rule" "jenkins_master_elb_access_https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"

  security_group_id        = "${aws_security_group.jenkins_master_sg.id}"
  source_security_group_id = "${aws_security_group.jenkins_master_elb_sg.id}"

  lifecycle {
    create_before_destroy  = false
  }
}

# Egress for ELB SG
resource "aws_security_group_rule" "jenkins_master_elb_sg_egress" {
  type                     = "egress"
  security_group_id        = "${aws_security_group.jenkins_master_elb_sg.id}"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "TCP"
  source_security_group_id = "${aws_security_group.jenkins_master_sg.id}"
}

resource "aws_security_group_rule" "jenkins_master_elb_access_http" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.jenkins_master_sg.id}"
  source_security_group_id = "${aws_security_group.jenkins_master_elb_sg.id}"
  lifecycle {
    create_before_destroy  = false
  }
}

resource "aws_security_group_rule" "master_slave_access" {
  type                     = "egress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "TCP"
  security_group_id        = "${aws_security_group.jenkins_master_sg.id}"
  source_security_group_id = "${aws_security_group.jenkins_slave.id}"
  lifecycle {
    create_before_destroy = false
  }
}

# resource "aws_iam_instance_profile" "jenkins" {
#   name = "${var.org}-Jenkins-${var.environment}"

#   role = "${aws_iam_role.jenkins.name}"


# resource "aws_iam_role" "jenkins" {
#   name = "${var.org}-Jenkins-Service-Int-${var.environment}"
#   path = "/"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Sid": "",
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "ec2.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# EOF
# }

# resource "aws_iam_role_policy" "jenkins" {
#   name   = "${var.org}-Jenkins-${var.environment}"
#   role   = "${aws_iam_role.jenkins.id}"
#   policy = "${file("${path.module}/iam_policy.json")}"



resource "aws_elb" "jenkins_master_elb" {
  name                      = "${var.org}-${var.environment}-Jenkins-Int-ELB"
  internal                  = true
  idle_timeout              = 400
  cross_zone_load_balancing = true
  connection_draining       = true

  subnets                   = ["${var.subnet_ids}"]

  security_groups           = [
                                "${aws_security_group.jenkins_master_elb_sg.id}"
                              ]
  instances                 = [
                                "${aws_instance.master.id}"
                              ]

#  access_logs {
#    bucket        = "${aws_s3_bucket.elb_access_log.bucket}"
#    bucket_prefix = "${aws_s3_bucket_object.elb_access_log_prefix.key}"
#    interval      = 5
#  }

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  listener {
    instance_port     = 443
    instance_protocol = "tcp"
    lb_port           = 443
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8080/login"
    interval            = 30
  }

  tags = "${merge(var.default_tags, map("Name", format("%s-%s-Jenkins-Int-ELBs", var.org, var.environment)))}"

  lifecycle {
    create_before_destroy = false
  }
}

# Chef JSON attributes for configuring Active Directory authentication
data "template_file" "chef_attributes" {
  template      = "${file(format("%s/chef_attributes.json.tpl", path.module))}"
  vars {
    domain_name = "${var.private_domain}"
    # domain_servers = "${join(",", formatlist("%s:3268", var.ad_servers))}"
  }
}

resource "aws_instance" "master" {
  instance_type          = "${var.instance_type}"
  # iam_instance_profile = "${aws_iam_instance_profile.jenkins.id}"
  ami                    = "${var.ami_id}"
  key_name               = "${var.conn_key_name}"
  subnet_id              = "${var.subnet_ids}"

  connection {
    type                 = "ssh"
    user                 = "${var.conn_user_name}"
    private_key          = "${file(var.conn_private_key)}"
  }
  vpc_security_group_ids = ["${concat(
                                    list(aws_security_group.jenkins_master_sg.id),
                                    var.vpc_security_group_ids
                                  )
                             }"]
  tags                   = "${merge(var.default_tags, map("Name", format("%s-%s-JenkinsMaster-EC2", var.org, var.environment)))}"

  provisioner "chef" {
    run_list                = ["role[base]","recipe[java::default]","recipe[jenkins::master]"]
    attributes_json         = "${data.template_file.chef_attributes.rendered}"
    node_name               = "jenkins"
    server_url              = "${var.chef_server_url}"
    fetch_chef_certificates = true
    recreate_client         = true
    user_name               = "${var.chef_user_name}"
    user_key                = "${file(var.chef_user_key)}"
    # version                 = "${var.version}"
    http_proxy              = "${var.http_proxy}"
    https_proxy             = "${var.https_proxy}"
    no_proxy                = ["${var.no_proxy}"]
    environment             = "${lower(format("%s-%s", var.org, var.environment))}"    
  }

}

# Add Cname to Route53 if available
resource "aws_route53_record" "jenkins" {
  count                   = "${length(var.route53_zone_id) > 0 ? 1 : 0}"
  zone_id                 = "${var.route53_zone_id}"
  name                    = "jenkins"
  type                    = "CNAME"
  ttl                     = "30"
  records                 = ["${aws_elb.jenkins_master_elb.dns_name}"]
}
