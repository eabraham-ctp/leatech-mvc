# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Active Directory - bootstrap

output "mvc-ad_dns_name" {
  value = "${aws_directory_service_directory.mvc-ad.name}"
}

output "mvc-ad_id" {
  value = "${aws_directory_service_directory.mvc-ad.id}"
}

output "directory_ip_addresses" {
  value = ["${aws_directory_service_directory.mvc-ad.dns_ip_addresses}"]
}

output "base_dn" {
  value = "CN=Users,${join(",", formatlist("DC=%s", split(".", "${aws_directory_service_directory.mvc-ad.name}")))}"
}

output "bind_dn" {
  value = "CN=LDAP User,CN=Users,${join(",", formatlist("DC=%s", split(".", "${aws_directory_service_directory.mvc-ad.name}")))}"
}
