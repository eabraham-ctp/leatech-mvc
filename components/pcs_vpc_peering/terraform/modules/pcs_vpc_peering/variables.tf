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

# variable "peer_acct_id" {}
variable "peer_acct_profile" {}
variable "peer_acct_cidr" {}
variable "vpc_id" {}
variable "peer_vpc_id" {}
variable "requester_profile" {}

variable allow_remote_vpc_dns_resolution {
  default = true
}

# Enable this to auto accepting peering only works if both VPCs are in the same account
variable peering_autoaccept {
  default = false
}
