# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Active Directory - bootstrap

/*output "mvc-ad_dns_ip_addresses" {
  value = "${aws_directory_service_directory.mvc-ad.dns_ip_addresses}"
}*/

output "mvc-ad_dns_name" {
  value = "${aws_directory_service_directory.mvc-ad.name}"
}

output "mvc-ad_id" {
  value = "${aws_directory_service_directory.mvc-ad.id}"
}

output "mvc-ad-dhcp-id" {
  value = "${aws_vpc_dhcp_options.mvc-ad-dhcp.id}"
}

output "win-role-ssm-profile-id" {
  value = "${aws_iam_instance_profile.win-role-ssm-profile.id}"
}

output "windows_admin_address" {
  value = "${aws_instance.windows_ad_server.private_ip}"
}

output "directory_ip_addresses" {
  value = ["${aws_directory_service_directory.mvc-ad.dns_ip_addresses}"]
}

output "base_dn" {
  value = "CN=Users,${join(",", formatlist("DC=%s", split(".", var.directory_name)))}"
}

output "bind_dn" {
  value = "CN=LDAP User,CN=Users,${join(",", formatlist("DC=%s", split(".", var.directory_name)))}"
}
