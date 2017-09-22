# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Active Directory - bootstrap

variable "org" {
description = "Organization or Business Unit"
}

variable "environment" {
description = "SDLC environment"
}

variable "vpc_id" {
  description = "The VPC which will host the server"
}

variable "directory_name" {
  description = "The Active Directory Name"
}

variable "directory_admin" {
  default = "Administrator"
  description = "The Active Directory Admin"
}

variable "directory_password" {
  description = "The Active Directory Password"
}

variable "domain_mode" {
  default = "Win2012"
  description = "The Domain Mode"
}

variable "forest_mode" {
  default = "Win2012"
  description = "The Forest Mode"
}

variable "private_subnet_ids" {
  description = "The IDs of all available subnets for the server (typically one per AZ)"
  type = "list"
}

variable "dhcp_domain_name" {
  description = "The DHCP Domain Name"
}

variable "key_name" {
  description = "Name of the SSH keypair to use in AWS."
}

variable "aws_region" {
  description = "AWS region to launch servers."
}

variable "instance_type" {
  description = "The EC2 instance type"
  default = "m4.large"
}

variable "default_tags" {
  description = "Default tag values to be applied to all resources"
  type        = "map"
}
