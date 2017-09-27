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

variable "conn_key_name" {
  description = "Name of the SSH keypair to use in AWS."
}

variable "region" {
  description = "AWS region to launch servers."
  default = "eu-west-1"
}

variable "instance_type" {
  description = "The EC2 instance type"
  default = "m4.large"
}

variable "default_tags" {
  description = "Default tag values to be applied to all resources"
  type        = "map"
}
