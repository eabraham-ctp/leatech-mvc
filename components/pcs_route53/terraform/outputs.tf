output "zone_id" {
	value = "${module.route53zone.zone_id}"
}

output "zone_association_identifier" {
	value = "${module.route53zone.zone_association_identifier}"
}

output "private_domain" {
  value = "${module.route53zone.private_domain}"
}
