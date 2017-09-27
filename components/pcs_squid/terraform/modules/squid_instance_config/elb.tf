resource "aws_elb" "squid_elb" {
  name                   = "${format("%s-%s-Squid-ELB", var.org, var.environment)}"
  internal               = true
  subnets                =  "${var.subnet_ids}"
  security_groups        = [ "${aws_security_group.sg_squid_elb.id}" ]
  idle_timeout           = 400
  cross_zone_load_balancing = true
  connection_draining    = true

  listener {
    instance_port        = "${var.squid_port}"
    instance_protocol    = "TCP"
    lb_port              = "${var.squid_port}"
    lb_protocol          = "TCP"
  }

  health_check {
    healthy_threshold    = 3
    unhealthy_threshold  = 5
    timeout              = 3
    target               = "TCP:${var.squid_port}"
    interval             = 90
  }
  tags                   = "${merge(var.default_tags, map("Name", format("%s-%s-Squid-proxy-access", var.org, var.environment)))}"

  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_proxy_protocol_policy" "proxy_access" {
  load_balancer  = "${aws_elb.squid_elb.name}"
  instance_ports = ["${var.squid_port}"]
}


# Add Cname to Route53 if available
resource "aws_route53_record" "proxy" {
  count                   = "${length(var.route53_zone_id) > 0 ? 1 : 0}"
  zone_id                 = "${var.route53_zone_id}"
  name                    = "proxy"
  type                    = "CNAME"
  ttl                     = "30"
  records                 = ["${aws_elb.squid_elb.dns_name}"]
}