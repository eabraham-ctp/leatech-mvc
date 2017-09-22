# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# IAM Roles

variable "region" {
  description = "The AWS region"
}

variable "org" {
  description = "Organization or Business Unit"
}

variable "environment" {
  description = "SDLC environment"
}

variable "default_tags" {
  description = "tags"
  type="map"
}

variable "kms_ami_key" {
  description = "key for encrypting AMIs"
}


variable "kms_general_key" {
  description = "key for encrypting general stuff"
}