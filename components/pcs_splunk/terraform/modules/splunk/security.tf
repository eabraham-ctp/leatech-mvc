
resource "aws_security_group" "elb" {
  # Splunk Elastic Load Balancer group
  name        = "${upper(var.org)}-${upper(var.environment)}-${var.app}-ELB-SG"
  vpc_id      = "${var.vpc_id}"
  tags        = "${merge(var.default_tags, map("Name", format("%s-%s-%s-ELB-SG", var.org, var.environment, var.app)))}"
}

resource "aws_security_group_rule" "common_to_splunk_elb_egress" {
  type                     = "egress"
  from_port                = "${var.elb_port}"
  to_port                  = "${var.elb_port}"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.elb.id}"
  security_group_id        = "${var.common_sg}"
}

resource "aws_security_group_rule" "vpn_to_splunk_elb_egress" {
  type                     = "egress"
  from_port                = "${var.elb_port}"
  to_port                  = "${var.elb_port}"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.elb.id}"
  security_group_id        = "${var.openvpn_sg}"
}

resource "aws_security_group_rule" "splunk_elb_common_ingress" {
  type                     = "ingress"
  from_port                = "${var.elb_port}"
  to_port                  = "${var.elb_port}"
  protocol                 = "tcp"
  source_security_group_id = "${var.common_sg}"
  security_group_id        = "${aws_security_group.elb.id}"
}

resource "aws_security_group_rule" "splunk_elb_vpn_ingress" {
  type                     = "ingress"
  from_port                = "${var.elb_port}"
  to_port                  = "${var.elb_port}"
  protocol                 = "tcp"
  source_security_group_id = "${var.openvpn_sg}"
  security_group_id        = "${aws_security_group.elb.id}"
}

resource "aws_security_group_rule" "splunk_elb_to_searcher_egress" {
  type                     = "egress"
  from_port                = "${var.httpport}"
  to_port                  = "${var.httpport}"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.instance.id}"
  security_group_id        = "${aws_security_group.elb.id}"
}

# Instance Security Group
resource "aws_security_group" "instance" {
  #Splunk instance
  name        = "${upper(var.org)}-${upper(var.environment)}-${var.app}-SG"
  vpc_id      = "${var.vpc_id}"
  tags        = "${merge(var.default_tags, map("Name", format("%s-%s-%s-SG", var.org, var.environment, var.app)))}"
}

resource "aws_security_group_rule" "cluster_ingress" {
  count                    = "${length(var.splunk_ports)}"
  type                     = "ingress"
  from_port                = "${element(var.splunk_ports, count.index)}"
  to_port                  = "${element(var.splunk_ports, count.index)}"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.instance.id}"
  security_group_id        = "${aws_security_group.instance.id}"
}

resource "aws_security_group_rule" "cluster_egress" {
  count                    = "${length(var.splunk_ports)}"
  type                     = "egress"
  from_port                = "${element(var.splunk_ports, count.index)}"
  to_port                  = "${element(var.splunk_ports, count.index)}"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.instance.id}"
  security_group_id        = "${aws_security_group.instance.id}"
}

resource "aws_security_group_rule" "aws_cli_egress" {
  #east, west  autoscaling and ec2 endpoints
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"] //["54.240.253.0/24","52.94.208.0/24"]
  security_group_id        = "${aws_security_group.instance.id}"
}

resource "aws_security_group_rule" "aws_cli_egress_http" {
  #east, west  autoscaling and ec2 endpoints
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"] //["54.240.253.0/24","52.94.208.0/24"]
  security_group_id        = "${aws_security_group.instance.id}"
}

resource "aws_security_group_rule" "splunk_common_ingress" {
  type                     = "ingress"
  from_port                = "${var.httpport}"
  to_port                  = "${var.httpport}"
  protocol                 = "tcp"
  source_security_group_id = "${var.common_sg}"
  security_group_id        = "${aws_security_group.instance.id}"
}

resource "aws_security_group_rule" "splunk_common_egress" {
  type                     = "egress"
  from_port                = "${var.httpport}"
  to_port                  = "${var.httpport}"
  protocol                 = "tcp"
  source_security_group_id = "${var.common_sg}"
  security_group_id        = "${aws_security_group.instance.id}"
}

resource "aws_security_group_rule" "splunk_vpn_ingress" {
  #Internet Access
  type                     = "ingress"
  from_port                = "${var.httpport}"
  to_port                  = "${var.httpport}"
  protocol                 = "tcp"
  source_security_group_id = "${var.openvpn_sg}"
  security_group_id        = "${aws_security_group.instance.id}"
}

resource "aws_security_group_rule" "splunk_vpn_egress" {
  type                     = "egress"
  from_port                = "${var.httpport}"
  to_port                  = "${var.httpport}"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.instance.id}"
  security_group_id        = "${var.openvpn_sg}"
}

resource "aws_security_group_rule" "splunk_elb_ingress" {
  #Internet Access
  type                     = "ingress"
  from_port                = "${var.httpport}"
  to_port                  = "${var.httpport}"
  protocol                 = "tcp"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.elb.id}"
  security_group_id        = "${aws_security_group.instance.id}"
}

resource "aws_security_group" "heavy_forwarder" {
  name        = "${upper(var.org)}-${upper(var.environment)}-${var.app}-Heavy-Forwarder-SG"
  vpc_id      = "${var.vpc_id}"
  tags        = "${merge(var.default_tags, map("Name", "${upper(var.org)}-${upper(var.environment)}-${var.app}-Heavy-Forwarder-SG"))}"
}

resource "aws_security_group" "searchhead" {
  name        = "${upper(var.org)}-${upper(var.environment)}-${var.app}-Searchhead-SG"
  vpc_id      = "${var.vpc_id}"
  tags        = "${merge(var.default_tags, map("Name", "${upper(var.org)}-${upper(var.environment)}-${var.app}-Searchhead-SG"))}"
}

resource "aws_security_group" "indexer" {
  name        = "${upper(var.org)}-${upper(var.environment)}-${var.app}-Indexer-SG"
  vpc_id      = "${var.vpc_id}"
  tags        = "${merge(var.default_tags, map("Name", "${upper(var.org)}-${upper(var.environment)}-${var.app}-Indexer-SG"))}"
}

resource "aws_security_group" "master" {
  name        = "${upper(var.org)}-${upper(var.environment)}-${var.app}-Master-Node-SG"
  vpc_id      = "${var.vpc_id}"
  tags        = "${merge(var.default_tags, map("Name", "${upper(var.org)}-${upper(var.environment)}-${var.app}-Master-Node-SG"))}"
}

resource "aws_security_group" "deployer" {
  name        = "${upper(var.org)}-${upper(var.environment)}-${var.app}-Deployer-SG"
  vpc_id      = "${var.vpc_id}"
  tags        = "${merge(var.default_tags, map("Name", "${upper(var.org)}-${upper(var.environment)}-${var.app}-Deployer-SG"))}"
}

resource "aws_security_group" "deployment" {
  name        = "${upper(var.org)}-${upper(var.environment)}-${var.app}-Deployment-Server-SG"
  vpc_id      = "${var.vpc_id}"
  tags        = "${merge(var.default_tags, map("Name", "${upper(var.org)}-${upper(var.environment)}-${var.app}-Deployment-Serverr-SG"))}"
}









