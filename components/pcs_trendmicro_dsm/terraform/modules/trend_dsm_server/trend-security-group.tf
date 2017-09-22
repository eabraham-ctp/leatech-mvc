# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Trend Server Marketplace
#
# Module for creating the Trend Deep Scan Serverfor Platform Common Services (PCS). This version uses
# Terraform scripts and Marketplace AMI
#
# Creates the security group for the trend micro server

resource "aws_security_group" "dsm_elb_sg" {
  # Applies to ELB
  vpc_id      = "${var.vpc_id}"
  name        = "${upper(var.org)}-${upper(var.group)}-${upper(var.environment)}-TrendMicroDSM-ELB-SG"
  description = "Security Group for Trend Server"
  tags        = "${merge(var.default_tags, map("Name", format("%s-%s-%s-TrendMicroDSM-ELB-SG", upper(var.org), upper(var.group), upper(var.environment) )))}"
}

resource "consul_keys" "dsm_elb_sg" {
  key {
    path                  = "aws/pcs/trendmicro/dsm_elb_sg"
    value                 = "${aws_security_group.dsm_elb_sg.id}",
    delete                = true
  }
}

resource "aws_security_group" "dsm_server_sg" {
  # Applies to trend Servers
  vpc_id      = "${var.vpc_id}"
  name        = "${upper(var.org)}-${upper(var.group)}-${upper(var.environment)}-TrendMicroDSM-Server-SG"
  description = "Security Group for Trend Server"
  tags        = "${merge(var.default_tags, map("Name", format("%s-%s-%s-TrendMicroDSM-Server-SG", upper(var.org), upper(var.group), upper(var.environment) )))}"
}

resource "consul_keys" "dsm_server_sg" {
  key {
    path                  = "aws/pcs/trendmicro/dsm_server_sg"
    value                 = "${aws_security_group.dsm_server_sg.id}",
    delete                = true
  }
}

resource "aws_security_group" "dsm_rds_access" {
  vpc_id      = "${var.vpc_id}"
  name        = "${upper(var.org)}-${upper(var.group)}-${upper(var.environment)}-TrendMicroDSM-Database-Access-sg"
  description = "Allow traffic for Trend to talk to RDS Instance"
  tags        = "${merge(var.default_tags, map("Name", format("%s-%s-%s-TrendMicroDSM-Database-Access-sg", upper(var.org), upper(var.group), upper(var.environment) )))}"
}

resource "consul_keys" "dsm_rds_access_sg" {
  key {
    path                  = "aws/pcs/trendmicro/dsm_rds_access_sg"
    value                 = "${aws_security_group.dsm_rds_access.id}",
    delete                = true
  }
}

resource "aws_security_group_rule" "dsm_agent_https" {
  # HTTPS @ ELB
  security_group_id         = "${aws_security_group.dsm_elb_sg.id}"
  type                      = "ingress"
  from_port                 = 443
  to_port                   = 443
  protocol                  = "tcp"
  source_security_group_id  = "${var.common_sg}"
}

resource "aws_security_group_rule" "dsm_agent_monitor-a" {
  #Trend Monitoring Ports @ ELB
  security_group_id         = "${aws_security_group.dsm_elb_sg.id}"
  type                      = "ingress"
  from_port                 = 4120
  to_port                   = 4120
  protocol                  = "tcp"
  source_security_group_id  = "${var.common_sg}"
}

resource "aws_security_group_rule" "dsm_agent_monitor-b" {
  #Trend Monitoring Ports @ ELB
  security_group_id         = "${aws_security_group.dsm_elb_sg.id}"
  type                      = "ingress"
  from_port                 = 4122
  to_port                   = 4122
  protocol                  = "tcp"
  source_security_group_id  = "${var.common_sg}"
}

resource "aws_security_group_rule" "dsm_server_syslog_ingress" {
  # SSH from Workstations to Servers
  security_group_id         = "${aws_security_group.dsm_server_sg.id}"
  type                      = "ingress"
  from_port                 = 1514
  to_port                   = 1514
  protocol                  = "udp"
  source_security_group_id  = "${aws_security_group.dsm_server_sg.id}" 
}

resource "aws_security_group_rule" "dsm_server_elb-a" {
  # ELB Access to Trend Servers
  security_group_id         = "${aws_security_group.dsm_server_sg.id}"
  type                      = "ingress"
  from_port                 = 443
  to_port                   = 443
  protocol                  = "tcp"
  source_security_group_id  = "${aws_security_group.dsm_elb_sg.id}" 
}

resource "aws_security_group_rule" "dsm_server_elb-b" {
  # ELB Access to Trend Server for monitoring
  security_group_id         = "${aws_security_group.dsm_server_sg.id}"
  type                      = "ingress"
  from_port                 = 4120
  to_port                   = 4120
  protocol                  = "tcp"
  source_security_group_id  = "${aws_security_group.dsm_elb_sg.id}" 
}

resource "aws_security_group_rule" "dsm_server_elb-c" {
  # ELB Access to Trend Server for monitoring
  security_group_id         = "${aws_security_group.dsm_server_sg.id}"
  type                      = "ingress"
  from_port                 = 4122
  to_port                   = 4122
  protocol                  = "tcp"
  source_security_group_id  = "${aws_security_group.dsm_elb_sg.id}" 
}

resource "aws_security_group_rule" "dsm_server_console_vpn" {
  security_group_id         = "${aws_security_group.dsm_elb_sg.id}"
  type                      = "ingress"
  from_port                 = 443
  to_port                   = 443
  protocol                  = "tcp"
  source_security_group_id  = "${var.openvpn_sg}" 
}

resource "aws_security_group_rule" "dsm_rds_ingress" {
  # Postgres to RDS from servers
  security_group_id         = "${aws_security_group.dsm_rds_access.id}"
  type                      = "ingress"
  from_port                 = 5432
  to_port                   = 5432
  protocol                  = "tcp"
  source_security_group_id  = "${aws_security_group.dsm_server_sg.id}" 
}

######## 
# Trend server egress definitions
########

resource "aws_security_group_rule" "dsm_server_egress_to_rds" {
  security_group_id         = "${aws_security_group.dsm_server_sg.id}"
  type                      = "egress"
  from_port                 = 5432
  to_port                   = 5432
  protocol                  = "tcp"
  source_security_group_id  = "${aws_security_group.dsm_rds_access.id}" 
}

resource "aws_security_group_rule" "dsm_server_https_egress" {
  security_group_id         = "${aws_security_group.dsm_server_sg.id}"
  type                      = "egress"
  from_port                 = 443
  to_port                   = 443
  protocol                  = "tcp"
  source_security_group_id  = "${aws_security_group.dsm_elb_sg.id}" 
}

resource "aws_security_group_rule" "dsm_server_monitor_egress-a" {
  security_group_id         = "${aws_security_group.dsm_server_sg.id}"
  type                      = "egress"
  from_port                 = 4120
  to_port                   = 4120
  protocol                  = "tcp"
  source_security_group_id  = "${aws_security_group.dsm_elb_sg.id}" 
}

resource "aws_security_group_rule" "dsm_server_monitor_egress-b" {
  security_group_id         = "${aws_security_group.dsm_server_sg.id}"
  type                      = "egress"
  from_port                 = 4122
  to_port                   = 4122
  protocol                  = "tcp"
  source_security_group_id  = "${aws_security_group.dsm_elb_sg.id}" 
}

resource "aws_security_group_rule" "dsm_server_proxy_egress" {
  security_group_id         = "${aws_security_group.dsm_server_sg.id}"
  type                      = "egress"
  from_port                 = 8080
  to_port                   = 8080
  protocol                  = "tcp"
  source_security_group_id  = "${var.squid_elb_sg}" 
}

# Egress for Syslog
resource "aws_security_group_rule" "dsm_server_syslog_egress" {
  security_group_id         = "${aws_security_group.dsm_server_sg.id}"
  type                      = "egress"
  from_port                 = 1514
  to_port                   = 1514
  protocol                  = "udp"
  source_security_group_id  = "${aws_security_group.dsm_server_sg.id}" 
}

######## 
# ELB server egress definitions
########

resource "aws_security_group_rule" "dsm_elb_egress_https" {
  security_group_id         = "${aws_security_group.dsm_elb_sg.id}"
  type                      = "egress"
  from_port                 = 443
  to_port                   = 443
  protocol                  = "tcp"
  source_security_group_id  = "${aws_security_group.dsm_server_sg.id}" 
}

resource "aws_security_group_rule" "dsm_elb_egress_monitor-a" {
  security_group_id         = "${aws_security_group.dsm_elb_sg.id}"
  type                      = "egress"
  from_port                 = 4120
  to_port                   = 4120
  protocol                  = "tcp"
  source_security_group_id  = "${aws_security_group.dsm_server_sg.id}" 
}

resource "aws_security_group_rule" "dsm_elb_egress_monitor-b" {
  security_group_id         = "${aws_security_group.dsm_elb_sg.id}"
  type                      = "egress"
  from_port                 = 4122
  to_port                   = 4122
  protocol                  = "tcp"
  source_security_group_id  = "${aws_security_group.dsm_server_sg.id}" 
}

######## 
# Common SG - Add outbound to trend ELB
########
resource "aws_security_group_rule" "https_egress_from_common_sg_to_tm_elb" {
  security_group_id         = "${var.common_sg}" 
  type                      = "egress"
  from_port                 = 443
  to_port                   = 443
  protocol                  = "tcp"
  source_security_group_id  = "${aws_security_group.dsm_elb_sg.id}" 
}

resource "aws_security_group_rule" "monitor4120_egress_from_common_sg_to_tm_elb" {
  security_group_id         = "${var.common_sg}" 
  type                      = "egress"
  from_port                 = 4120
  to_port                   = 4120
  protocol                  = "tcp"
  source_security_group_id  = "${aws_security_group.dsm_elb_sg.id}" 
}

resource "aws_security_group_rule" "monitor4122_egress_from_common_sg_to_tm_elb" {
  security_group_id         = "${var.common_sg}" 
  type                      = "egress"
  from_port                 = 4122
  to_port                   = 4122
  protocol                  = "tcp"
  source_security_group_id  = "${aws_security_group.dsm_elb_sg.id}" 
}
