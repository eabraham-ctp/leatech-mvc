data "template_file" "user_data" {
  template = "${file("${path.module}/squid_instance_userdata.tpl")}"
  vars {
    region            = "${var.region}"
    backend_bucket_name = "${var.backend_bucket_name}",
    squid_conf_prefix = "${var.squid_conf_prefix}",
  }
}

resource "aws_launch_configuration" "squid_launch_conf" {
  name_prefix          = "${var.org}-${var.environment}-Squid-LC-"
  image_id             = "${var.ami_id}"
  instance_type        = "${var.ec2_squid_instance_type}"
  key_name             = "${var.conn_key_name}"
  security_groups      = ["${concat(
                                    list(aws_security_group.sg_squid_instances.id),
                                    var.vpc_security_group_ids
                                  )
                          }"]
  iam_instance_profile = "${var.squid_instance_profile}"
  user_data            = "${data.template_file.user_data.rendered}"
  associate_public_ip_address = false
  lifecycle { create_before_destroy = true }
  root_block_device { volume_size = 100 }  
}

resource "aws_autoscaling_group" "squid_asg" {
  name_prefix          = "${var.org}-${var.environment}-Squid-EC2-"
  launch_configuration = "${aws_launch_configuration.squid_launch_conf.name}"
  min_size             = 1
  max_size             = 6
  load_balancers       = ["${aws_elb.squid_elb.id}"]
  vpc_zone_identifier  = ["${var.subnet_ids}"]
  tags = [
        "${map(
          "key", "Name",
          "value", "${var.org}-${var.environment}-Squid-EC2",
          "propagate_at_launch", true)
        }",
        "${map(
          "key", "ApplicationName",
          "value", "${var.ApplicationName}",
          "propagate_at_launch", true)
        }",
        "${map(
          "key", "TechnicalOwner",
          "value", "${var.default_tags["TechnicalOwner"]}",
          "propagate_at_launch", true)
        }",
        "${map(
          "key", "BusinessOwner",
          "value", "${var.default_tags["BusinessOwner"]}",
          "propagate_at_launch", true)
        }",
        "${map(
          "key", "Environment",
          "value", "${var.default_tags["Environment"]}",
          "propagate_at_launch", true)
        }",
        "${map(
          "key", "Organization",
          "value", "${var.default_tags["Organization"]}",
          "propagate_at_launch", true)
        }"
  ]
  depends_on           = ["aws_launch_configuration.squid_launch_conf"]
}

resource "aws_autoscaling_policy" "squid_asg_scaleup_policy" {
  name                   = "squid_asg_scaleup_policy"
  scaling_adjustment     = 50
  adjustment_type        = "PercentChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.squid_asg.name}"
}

resource "aws_autoscaling_policy" "squid_asg_scaledown_policy" {
  name                   = "squid_asg_scaledown_policy"
  scaling_adjustment     = -33
  adjustment_type        = "PercentChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.squid_asg.name}"
  depends_on           = ["aws_autoscaling_policy.squid_asg_scaleup_policy"] # Stops timing clash
}
