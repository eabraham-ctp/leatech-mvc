resource "aws_route53_zone" "private_zone" {
  name   		= "${var.fqdn}"
  vpc_id 		= "${var.vpc_id}"
  tags        	= "${merge(var.default_tags, map("Name", format("%s-%s-%s-Route53--zone", upper(var.org), upper(var.group), upper(var.environment) )))}"
  comment		= "private route53 zone "
}
