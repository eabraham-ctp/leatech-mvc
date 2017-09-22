#--------------------------------------------------------------
# This module creates resources necessary for
# creating a Security Common Services(SCS) VPC
#--------------------------------------------------------------

resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr_block}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name        = "${var.vpc_name}"
    environment = "${var.environment}"
    lifecycle   = "${var.lifecycle}"
    contact     = "${var.contact}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpn_gateway_attachment" "vpn_vgw_attachment" {
  vpc_id         = "${aws_vpc.vpc.id}"
  vpn_gateway_id = "${var.vpn_vgw_id}"
}

resource "aws_vpc_dhcp_options" "dhcp_option_set" {
  domain_name_servers = "${var.domain_name_servers}"
  domain_name         = "${var.domain}"
  tags {
    Name        = "${var.vpc_name}-DNS-NET.DHCP-INT"
    environment = "${var.environment}"
    lifecycle   = "${var.lifecycle}"
    contact     = "${var.contact}"
  }
}

resource "aws_vpc_dhcp_options_association" "dhcp_options_association" {
  vpc_id          = "${aws_vpc.vpc.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.dhcp_option_set.id}"
}

