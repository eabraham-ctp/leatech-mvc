# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Squid

output "squid_elb_sg" {
  value = "${aws_security_group.sg_squid_elb.id}"
}

output "squid_elb_address" {
  value = "${aws_elb.squid_elb.dns_name}"
}

output "squid_elb_id" {
  value = "${aws_elb.squid_elb.id}"
}
