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

variable "default_tags" {
	description = "tags to apply to resources on creation"
	type        = "map"
}

variable "vpc_id" {
	description = "vpc_id"
}