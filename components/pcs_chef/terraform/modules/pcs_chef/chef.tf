#--------------------------------------------------------------
# This module creates chef-server instances
#--------------------------------------------------------------


resource "aws_security_group" "chef_elb_sg" {
  name        = "${var.org}-${var.environment}-ChefELB-SG"
  vpc_id      = "${var.vpc_id}"
  description = "Chef ELB security group"
  tags        = "${merge(var.default_tags, map("Name", format("%s-%s-ChefELB-sg", var.org, var.environment)))}"

  lifecycle {
    ignore_changes = [
      "tags"]
  }
}

resource "aws_security_group" "chef_sg" {
  name        = "${var.org}-${var.environment}-ChefEC2-SG"
  vpc_id      = "${var.vpc_id}"
  description = "Chef-server security group"
  tags        = "${merge(var.default_tags, map("Name", format("%s-%s-ChefEc2-sg", var.org, var.environment)))}"

  lifecycle {
    ignore_changes = [
      "tags"]
  }
}

resource "aws_security_group_rule" "chef_server_elb_to_instance_access_https" {
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.chef_sg.id}"
  security_group_id        = "${aws_security_group.chef_elb_sg.id}"
  lifecycle {
    create_before_destroy  = false
  }
}

resource "aws_security_group_rule" "chef_server_elb_access_https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.chef_sg.id}"
  source_security_group_id = "${aws_security_group.chef_elb_sg.id}"
  lifecycle {
    create_before_destroy  = false
  }
}


# HTTP access restricted to the ELB to instance SG only used for health check
resource "aws_security_group_rule" "chef_server_elb_to_instance_access_http" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "TCP"
  source_security_group_id = "${aws_security_group.chef_sg.id}"
  security_group_id        = "${aws_security_group.chef_elb_sg.id}"
  lifecycle {
    create_before_destroy  = false
  }
}

resource "aws_security_group_rule" "chef_server_elb_access_http" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "TCP"
  security_group_id        = "${aws_security_group.chef_sg.id}"
  source_security_group_id = "${aws_security_group.chef_elb_sg.id}"
  lifecycle {
    create_before_destroy  = false
  }
}


# Ingress allow from common_sg
resource "aws_security_group_rule" "elb_sg_ingress_from_common_sg" {
  type = "ingress"
  security_group_id        = "${aws_security_group.chef_elb_sg.id}"
  from_port                = "443"
  to_port                  = "443"
  protocol                 = "TCP"
  source_security_group_id = "${var.common_sg}" 
}

# Egress added to common_sg
resource "aws_security_group_rule" "common_sg_egress_to_elb_sg" {
  type                     = "egress"
  security_group_id        = "${var.common_sg}"
  from_port                = "443"
  to_port                  = "443"
  protocol                 = "TCP"
  source_security_group_id = "${aws_security_group.chef_elb_sg.id}"
}


# OpenVpn access to ELB
resource "aws_security_group_rule" "chef_server_elb_inbound_https_from_openvpn" {
  count                    = "${var.openvpn_enabled == "true" ? 1 : 0}"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "TCP"
  security_group_id        = "${aws_security_group.chef_elb_sg.id}"
  source_security_group_id = "${var.openvpn_sg}" # access from open VPN clients
}

# resource "aws_iam_instance_profile" "chef" {
#   name = "${var.org}-Chef-${var.environment}"

#   role = "${aws_iam_role.chef.name}"
#   depends_on = [
#     "aws_iam_role.chef"]
# }
# # <Org/BU>-<Role>-<User|Service>-<Type SAML|Int|Ext>-<Environment>
# resource "aws_iam_role" "chef" {
#   name = "${var.org}-${var.environment}-Chef-Service-Int"
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

# resource "aws_iam_role_policy" "chef" {
#   name = "${var.org}-${var.environment}-Chef"
#   role = "${aws_iam_role.chef.id}"
#   policy = "${file("${path.module}/iam_policy.json")}"

#   depends_on = [
#     "aws_iam_instance_profile.chef"]
# }

resource "aws_elb" "chef" {
  name     = "${var.org}-${var.environment}-Chef-INT-ELB"
  tags     = "${merge(var.default_tags, map("Name", format("%s-%s-Chef-Int-ELB", var.org, var.environment)))}"
  subnets  = ["${split(",", var.subnet_ids)}"]
  internal = true
  security_groups = [
                      "${aws_security_group.chef_elb_sg.id}"
                    ]
  instances       = [
                    "${aws_instance.chef_server.id}"
                    ]

  idle_timeout              = 400
  cross_zone_load_balancing = true
  connection_draining       = true

  listener {
    instance_port     = 80
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
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTPS:443/login"
    interval            = 30
  }

  depends_on = [
    "aws_security_group.chef_elb_sg"
  ]

  lifecycle {
    create_before_destroy = false
  }
}

data "template_file" "chef_server_rb" {
  template = "${file("${path.module}/chef-server.rb.tpl")}"

  vars {
        chef_elb = "${aws_elb.chef.dns_name}"
        # ldapBaseDN = "${var.base_dn}"
        # ldapBindDn = "${var.bind_dn}"
        # ldapBindPassword = "${var.bind_secret}"
        # #ldapGroupDn = "${var.group_dn}"
        # ldapLoginAttribute = "${var.login_attribute}"
        # ldapHost = "${var.ldap_host}"
        # ldapPort = "${var.ldap_port}"
  }
}

data "template_file" "install_chef" {
  template            = "${file("${path.module}/install_chef.sh.tpl")}"
  vars {
    squid_elb_address = "${var.squid_elb_address}"
    install_url       = "${var.install_url}"
    no_proxy          = "${var.no_proxy}"
  }
}

data "template_file" "chef-reconfigure" {
  template          = "${file("${path.module}/chef-reconfigure.sh.tpl")}"
  vars {
    admin_username  = "${var.admin_username}" 
    admin_password  = "${var.admin_password}"
    admin_firstname = "${var.admin_firstname}"
    admin_lastname  = "${var.admin_lastname}" 
    email_address   = "${var.email_address}"
    conn_user_name  = "${var.conn_user_name}"  # Admin keys will be created here to be downloaded
    org             = "${lower(var.org)}"
    environment     = "${lower(var.environment)}"
  }
}

resource "aws_instance" "chef_server" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    type                 = "ssh"
    user                 = "${var.conn_user_name}"
    private_key          = "${file(var.conn_private_key)}"
    host                 = "${aws_instance.chef_server.private_ip}"
  }
  tags                   = "${merge(
                                var.default_tags, 
                                map("Name", 
                                      format("%s-%s-Chef-EC2", 
                                        var.org, 
                                        var.environment
                                      )
                                    )
                                )
                            }"
  instance_type          = "${var.instance_type}"
  # iam_instance_profile   = "${aws_iam_instance_profile.chef.id}"
  ami                    = "${var.ami_id}"
  vpc_security_group_ids = ["${concat(
                                    list(aws_security_group.chef_sg.id),
                                    var.vpc_security_group_ids
                                  )
                             }"]
  subnet_id              = "${element(split(",", var.subnet_ids), count.index)}"
  key_name               = "${var.conn_key_name}"

  provisioner "file" {
    source               = "${path.module}/setHostname.sh"
    destination          = "/tmp/setHostname.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setHostname.sh",
      "sudo /tmp/setHostname.sh ${var.hostname}-${terraform.env}"
    ]
  }
}

resource "null_resource" "chef_install" {
  connection {
    user           = "${var.conn_user_name}"
    private_key    = "${file(var.conn_private_key)}"
    host           = "${aws_instance.chef_server.private_ip}"
  }
  provisioner "file" {
    content        = "${data.template_file.install_chef.rendered}"
    destination    = "/tmp/install_chef.sh"
  }
  provisioner "remote-exec" {
    inline         = [
                        "sudo bash /tmp/install_chef.sh ${var.squid_elb_address}"
                      ]
  }
  depends_on       = [
                        "aws_instance.chef_server",
                        "aws_elb.chef"
                     ]
}

resource "null_resource" "chef_reconfigure" {
  connection {
    user           = "${var.conn_user_name}"
    private_key    = "${file(var.conn_private_key)}"
    host           = "${aws_instance.chef_server.private_ip}"
  }

  provisioner "file" {
    content = "${data.template_file.chef-reconfigure.rendered}"
    destination = "/tmp/chef-reconfigure.sh"
  }

  provisioner "file" {
    content = "${data.template_file.chef_server_rb.rendered}"
    destination = "/tmp/chef-server.rb"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp /tmp/chef-server.rb /etc/opscode/chef-server.rb",
      "chmod +x /tmp/chef-reconfigure.sh",
      "sudo /tmp/chef-reconfigure.sh"
    ]
  }
  depends_on = [
    "aws_instance.chef_server",
    "aws_elb.chef",
    "null_resource.chef_install"
  ]
}

# Add Cname to Route53 if available
resource "aws_route53_record" "chef" {
  count                   = "${length(var.route53_zone_id) > 0 ? 1 : 0}"
  zone_id                 = "${var.route53_zone_id}"
  name                    = "chef"
  type                    = "CNAME"
  ttl                     = "30"
  records                 = ["${aws_elb.chef.dns_name}"]
}
