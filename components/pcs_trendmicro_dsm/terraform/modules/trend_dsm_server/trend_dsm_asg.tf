

data "template_file" "user_data" {
  template = "${file("${path.module}/templates/user_data.tpl")}"
  vars {
    squid_elb_address          = "${var.squid_elb_address}",
    dsm_db_username            = "${var.dsm_db_username}"
    dsm_db_password            = "${var.dsm_db_password}",
    dsm_db_hostname            = "${aws_db_instance.tm_server_rds.address}",
    dsm_db_instance_name       = "${var.dsm_db_instance_name}",
    dsm_db_type                = "${var.dsm_db_type}",
    dsm_managerport            = "${var.dsm_managerport}",
    dsm_heartbeatport          = "${var.dsm_heartbeatport}",

    dsm_username               = "${var.dsm_username}",
    dsm_password               = "${var.dsm_password}",
    dsm_elb_url                = "${aws_route53_record.cname.fqdn}"
    dsm_elb_name               = "${aws_elb.tm_server_elb.name}"
    dsm_region                 = "${var.region}"

    squid_elb_address          = "${element(split(":",var.squid_elb_address),0)}" 
    squid_elb_port             = "${element(split(":",var.squid_elb_address),1)}" 
  }

  depends_on                   = [ "aws_db_instance.tm_server_rds" ]
}

resource "aws_launch_configuration" "trend_launch_conf" {
  name_prefix = "${upper(var.org)}-${upper(var.group)}-${upper(var.environment)}-TrendMicroDSM-LC-"
  image_id             = "${var.tm_ami_id}"
  instance_type        = "${var.instance_type}"
  key_name             = "${var.conn_key_name}"
  security_groups      = ["${concat(
                                    list(aws_security_group.dsm_server_sg.id),
                                         var.vpc_security_group_ids
                                  )
                             }"]
  iam_instance_profile = "${aws_iam_instance_profile.tm_metering.id}"
  user_data            = "${data.template_file.user_data.rendered}"
  associate_public_ip_address = false
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "trend_asg" {
  name_prefix = "${upper(var.org)}-${upper(var.group)}-${upper(var.environment)}-TrendMicroDSM-ASG-"
  launch_configuration = "${aws_launch_configuration.trend_launch_conf.name}"
  min_size             = 1
  max_size             = 1
  load_balancers       = ["${aws_elb.tm_server_elb.id}"]
  vpc_zone_identifier  = ["${var.security_subnet_ids}"]

  tags = [
        "${map(
          "key", "Name",
          "value", "${upper(var.org)}-${upper(var.group)}-${upper(var.environment)}-TrendMicro-EC2",
          "propagate_at_launch", true)
        }",
        "${map(
          "key", "ApplicationName",
          "value", "${var.default_tags["ApplicationName"]}",
          "propagate_at_launch", true)
        }",
        "${map(
          "key", "TechnicalResource",
          "value", "${var.default_tags["TechnicalResource"]}",
          "propagate_at_launch", true)
        }",
        "${map(
          "key", "BusinessOwner",
          "value", "${var.default_tags["BusinessOwner"]}",
          "propagate_at_launch", true)
        }",
        "${map(
          "key", "Environment",
          "value", "${var.environment}",
          "propagate_at_launch", true)
        }",
        "${map(
          "key", "Organization",
          "value", "${var.org}",
          "propagate_at_launch", true)
        }"
  ]

  depends_on           = [ "aws_launch_configuration.trend_launch_conf", 
                          "aws_db_instance.tm_server_rds"
                        ]
}
