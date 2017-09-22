resource "aws_elb" "tm_server_elb" {
  
  name                        = "${upper(var.org)}-${upper(var.group)}-${upper(var.environment)}-TrendMicroDSM-ELB"
  subnets                     = [ "${var.security_subnet_ids}" ] 
  internal                    = "true"
  security_groups             = [ "${aws_security_group.dsm_elb_sg.id}",
                                  "${var.common_sg}" ]

  listener {
    instance_port             = 443
    instance_protocol         = "https"
    lb_port                   = 443
    lb_protocol               = "https"
    ssl_certificate_id        = "${aws_iam_server_certificate.registry.arn}"
  }

  listener {
    instance_port             = 4120
    instance_protocol         = "tcp"
    lb_port                   = 4120
    lb_protocol               = "tcp"
  }

  listener {
    instance_port             = 4122
    instance_protocol         = "tcp"
    lb_port                   = 4122
    lb_protocol               = "tcp"
  }

  health_check {
    healthy_threshold         = "${var.elb_healthy_threshold}"
    unhealthy_threshold       = "${var.elb_unhealthy_threshold}"
    timeout                   = "${var.elb_timeout}"
    target                    = "${var.elb_health_check_target}"
    interval                  = "${var.elb_health_check_interval}"
  }

  cross_zone_load_balancing   = false
  idle_timeout                = 600
  connection_draining         = true
  connection_draining_timeout = 400

}

resource "aws_route53_record" "cname" {
  zone_id                     = "${var.zone_id}"
  name                        = "trend"
  type                        = "CNAME"
  ttl                         = "1"
  records                     = ["${aws_elb.tm_server_elb.dns_name}"]
}

resource "consul_keys" "trend_fqdn" {
  key {
    path                      = "aws/pcs/trendmicro/trend_fqdn"
    value                     = "${aws_route53_record.cname.fqdn}",
    delete                    = true
  }
}
