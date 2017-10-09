# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Vault - bootstrap

output "url" {
  value = "${aws_elb.search.dns_name}"
}


