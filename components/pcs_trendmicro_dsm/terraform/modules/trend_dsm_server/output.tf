
output "dsm_elb_url" {
	value = "${aws_elb.tm_server_elb.dns_name}"
}

output "trend_fqdn" {
	value = "${aws_route53_record.cname.fqdn}"
}
