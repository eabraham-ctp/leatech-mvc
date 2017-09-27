output "zone_association_identifier" {
	value = "${aws_route53_zone.private_zone.id}"
}

output "zone_id" {
	value = "${aws_route53_zone.private_zone.id}"
}

output "private_domain" {
  value = "${lower(var.fqdn)}"
}
