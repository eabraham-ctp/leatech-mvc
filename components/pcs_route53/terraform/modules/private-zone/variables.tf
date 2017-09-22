##############
# These values should be provided by TFVARS
##############

variable "fqdn" {
	description = "full domain to be configured in Route53"
}

variable "default_tags" {
	description = "tags to apply to resources on creation"
	type        = "map"
}

##############
# These values should be provided by Consul
##############

variable "vpc_id" {
	description = "vpc to link the zone to"
}

variable "region" {
	description = "region"
}

variable "org" {
	description = "org"
}

variable "group" {
	description = "group"
}

variable "environment" {
	description = "environment"
}
