# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Common Terraform Modules
# VPC

# The VPC itself (other resources will be created and attached)
resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr_block}"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = "${merge(var.default_tags, map("Name", format("%s-%s-VPC", var.org, var.environment)))}"
  lifecycle {
    create_before_destroy = true
  }
}

# # The VPN gateway attachment, if one was passed in
# resource "aws_vpn_gateway_attachment" "vpn_vgw_attachment" {
#   count               = "${var.attach_vpn_gateway}"
#   vpc_id              = "${aws_vpc.vpc.id}"
#   vpn_gateway_id      = "${var.vpn_vgw_id}"
# }

# A custom DHCP options set, included only if custom domain name servers were passed in
resource "aws_vpc_dhcp_options" "dhcp_option_set" {
  count               = "${length(var.domain_name_servers) > 0 ? 1 : 0}"
  domain_name_servers = "${var.domain_name_servers}"
  domain_name         = "${var.domain}"
  tags                = "${merge(var.default_tags, map("Name", format("%s-%s", var.org, var.environment)))}"
}

resource "aws_vpc_dhcp_options_association" "dhcp_options_association" {
  count               = "${length(var.domain_name_servers) > 0 ? 1 : 0}"
  vpc_id              = "${aws_vpc.vpc.id}"
  dhcp_options_id     = "${aws_vpc_dhcp_options.dhcp_option_set.id}"
}
