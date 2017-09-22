# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# One time init resources
#

# variable "accountno" {
#   description = "The full name of the hosting VPC (used in naming and tagging resources)"
# }
#
# variable "keyadmin" {
#   description = "The VPC which will host the server"
# }
#
# variable "keyusers" {
#   description = "The VPC which will host the server"
# }
#
variable "default_tags" {
  description = "Default tag values to be applied to all resources"
  type = "map"
}

variable "environment" {
  description = "SDLC environment"
}

variable "region" {
  description = "The AWS region"
}

variable "org" {
  description = "Name of organization"
}

variable "kms_description" {
  type = "string"
}

variable "kms_name" {
  type = "string"
}