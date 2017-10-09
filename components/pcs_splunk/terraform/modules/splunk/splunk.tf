

###################### Search Load Balancer ######################

resource "aws_elb" "search" {
  name = "${upper(var.org)}-${upper(var.environment)}-${var.app}-ELB"
  tags {
    Name = "${upper(var.org)}-${upper(var.environment)}-${var.app}-ELB"
  }
  internal        = true
  subnets         = ["${split(",", var.subnets)}"]
  security_groups = ["${aws_security_group.elb.id}"]
  listener {
    instance_port     = "${var.httpport}"
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold    =  2
    unhealthy_threshold  =  2
    timeout              =  3
    target               =  "HTTP:${var.httpport}/en-US/account/login"
    interval             =  5
  }
  cross_zone_load_balancing    =  true
  idle_timeout                 =  400
  connection_draining          =  true
  connection_draining_timeout  =  400
}

resource "aws_lb_cookie_stickiness_policy" "search" {
  name                      =  "${upper(var.org)}-${upper(var.environment)}-${var.app}-ELB-Cookie-Stickiness"
  load_balancer             =  "${aws_elb.search.id}"
  lb_port                   =  80
  cookie_expiration_period  =  1800
}

resource "aws_app_cookie_stickiness_policy" "splunk" {
  name            = "${upper(var.org)}-${upper(var.environment)}-${var.app}-ELB-App-Stickiness"
  load_balancer   = "${aws_elb.search.id}"
  lb_port         = 80
  cookie_name     = "session_id_${var.httpport}"
}

###################### Deployment Server ###################

resource "aws_instance" "deploymentserver" {
  connection {
    user = "${var.instance_user}"
  }
  tags {
    Name = "${upper(var.org)}-${upper(var.environment)}-${var.app}-Deployment-Server-EC2"
  }
  ami                         = "${var.ami}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  private_ip                  = "${var.deploymentserver_ip}"
  subnet_id                   = "${element(split(",", var.subnets), "0")}"
  user_data                   = "${data.template_file.user_data_deploymentserver.rendered}"
  iam_instance_profile        = "${aws_iam_instance_profile.splunk.name}"
  vpc_security_group_ids =    ["${concat(
                                    list(aws_security_group.instance.id, aws_security_group.deployment.id),
                                    var.vpc_security_group_ids
                                  )
                              }"]
}

###################### CLuster Master Node ###################

resource "aws_instance" "master" {
  connection {
    user = "${var.instance_user}"
  }
  tags {
    Name = "${upper(var.org)}-${upper(var.environment)}-${var.app}-Master-Node-EC2"
  }
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name = "${var.key_name}"
  subnet_id = "${element(split(",", var.subnets), "0")}"
  user_data = "${data.template_file.user_data_master.rendered}"
  iam_instance_profile = "${aws_iam_instance_profile.splunk.name}"
  vpc_security_group_ids =    ["${concat(
                                    list(aws_security_group.instance.id, aws_security_group.master.id, aws_security_group.deployer.id),
                                    var.vpc_security_group_ids
                                  )
                              }"]
}

###################### Heavy Forwarder #####################
resource "aws_launch_configuration" "forwarder" {
  name_prefix = "${upper(var.org)}-${upper(var.environment)}-${var.app}-Forwarder-LC-"
  connection {
    user = "${var.instance_user}"
  }
  image_id                    = "${var.ami}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  security_groups =           ["${concat(
                                    list(aws_security_group.instance.id, aws_security_group.heavy_forwarder.id),
                                    var.vpc_security_group_ids
                                  )
                              }"]
  iam_instance_profile        = "${aws_iam_instance_profile.splunk.name}"
  user_data                   = "${data.template_file.user_data_forwarder.rendered}"
}

resource "aws_autoscaling_group" "forwarder" {
  name = "${upper(var.org)}-${upper(var.environment)}-${var.app}-Forwarder-ASG"
  availability_zones         = ["${split(",", var.availability_zones)}"]
  vpc_zone_identifier        = ["${split(",", var.subnets)}"]
  max_size                   = 1
  min_size                   = 1
  desired_capacity           = 1
  health_check_grace_period  = 300
  health_check_type          = "EC2"
  launch_configuration       = "${aws_launch_configuration.forwarder.name}"
  
  tag {
    key                 = "Name"
    value               = "${upper(var.org)}-${upper(var.environment)}-${var.app}-Forwarder-EC2"
    propagate_at_launch = true
  }
}


###################### Indexer #############################
resource "aws_launch_configuration" "indexer" {
  name_prefix = "${upper(var.org)}-${upper(var.environment)}-${var.app}-Indexer-LC-"
  connection {
    user = "${var.instance_user}"
  }
  image_id                    = "${var.ami}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  security_groups =           ["${concat(
                                    list(aws_security_group.instance.id, aws_security_group.indexer.id),
                                    var.vpc_security_group_ids
                                  )
                              }"]
  iam_instance_profile        = "${aws_iam_instance_profile.splunk.name}"
  user_data                   = "${data.template_file.user_data_indexer.rendered}"
}

resource "aws_autoscaling_group" "indexer" {
  name = "${upper(var.org)}-${upper(var.environment)}-${var.app}-Indexer-ASG"
  availability_zones         = ["${split(",", var.availability_zones)}"]
  vpc_zone_identifier        = ["${split(",", var.subnets)}"]
  max_size                   = "${var.replication_factor}"
  min_size                   = "${var.replication_factor}"
  desired_capacity           = "${var.replication_factor}"
  health_check_grace_period  = 300
  health_check_type          = "EC2"
  launch_configuration       = "${aws_launch_configuration.indexer.name}"
  
  tag {
    key                 = "Name"
    value               = "${upper(var.org)}-${upper(var.environment)}-${var.app}-Indexer-EC2"
    propagate_at_launch = true
  }
}

###################### Searcher  ######################
resource "aws_launch_configuration" "searchhead" {
  name_prefix = "${upper(var.org)}-${upper(var.environment)}-${var.app}-Searcher-LC-"
  connection {
    user = "${var.instance_user}"
  }
  image_id                    = "${var.ami}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  user_data                   = "${data.template_file.user_data_searchhead.rendered}"
  iam_instance_profile        = "${aws_iam_instance_profile.splunk.name}"
  security_groups =           ["${concat(
                                    list(aws_security_group.instance.id, aws_security_group.searchhead.id),
                                    var.vpc_security_group_ids
                                  )
                              }"]
  
}

resource "aws_autoscaling_group" "searchhead" {
  name = "${upper(var.org)}-${upper(var.environment)}-${var.app}-Searcher-ASG"
  availability_zones         = ["${split(",", var.availability_zones)}"]
  vpc_zone_identifier        = ["${split(",", var.subnets)}"]
  min_size                   = "${var.search_factor}"
  max_size                   = "${var.search_factor}"
  desired_capacity           = "${var.search_factor}"
  health_check_grace_period  = 300
  health_check_type          = "EC2"
  launch_configuration       = "${aws_launch_configuration.searchhead.name}"
  load_balancers             = ["${aws_elb.search.name}"]
  
  tag {
    key                 = "Name"
    value               = "${upper(var.org)}-${upper(var.environment)}-${var.app}-Searcher-EC2"
    propagate_at_launch = true
  }
}
