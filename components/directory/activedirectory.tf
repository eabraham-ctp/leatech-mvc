# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Active Directory - bootstrap

# Create Simple AD using terraform
resource "aws_directory_service_directory" "mvc-ad" {
  type     = "SimpleAD"
  size     = "Small"
  name     = "${var.directory_name}"
  password = "${var.directory_password}"
 
  vpc_settings {
    vpc_id     = "${var.vpc_id}"
    subnet_ids = "${var.private_subnet_ids}"
  }
}
 
# Create a custom DHCP Option Set and attach it to the VPC
resource "aws_vpc_dhcp_options" "mvc-ad-dhcp" {
  domain_name          = "${var.dhcp_domain_name}"
  domain_name_servers  = ["${aws_directory_service_directory.mvc-ad.dns_ip_addresses}"]
  ntp_servers          = ["${aws_directory_service_directory.mvc-ad.dns_ip_addresses}"]
  netbios_name_servers = ["${aws_directory_service_directory.mvc-ad.dns_ip_addresses}"]
  netbios_node_type    = 2
  tags = "${merge(var.default_tags, map("Name", format("%s-DirectoryJoin-%s", var.org, var.environment)))}"

}

resource "aws_vpc_dhcp_options_association" "mvc-dns" {
  vpc_id          = "${var.vpc_id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.mvc-ad-dhcp.id}"
}
