# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Common network modules
# Subnets - Base Subnet
#
# Creates one subnet per availability zone with the same name prefix (App, Web, Data, etc)

variable "vpc_name" {
  description = "The base VPC name, such as PCS-Prod-USE1"
  type = "string"
}

variable "org" {
  description = "Organization or Business Unit"
}

variable "environment" {
  description = "SDLC environment"
}

variable "subnet_name" {
  description = "The descriptive name for this set of subnets (App, Web, Data, etc)"
}

variable "subnet_cidrs" {
  description = "The CIDR blocks assigned to the subnets"
  type = "list"
}

variable "saml_provider" {
  description = "An optional SAML provider for federated IAM roles, format arn:aws:iam::<AWS-account-ID>:saml-provider/<provider-name>"
  default = ""
  type = "string"
}

variable "vpc_id" {
  description = "The VPC in which to create the private subnets"
  type = "string"
}

variable "azs" {
  description = "The availbility zones in which to place the private subnets"
  type = "list"
}

variable "vpn_vgw_ids" {
  description = "The IDs of any VPN gateways for the VPC, for route propagation"
  type = "list"
}

variable "nat_gateway_ids" {
  description = "IDs for outbound NAT gateways, for routing"
  default = []
  type = "list"
}

# Peering to PCS VPC
variable "pcs_vpc_peering_id" {
  default = ""
  type = "string"
}
variable "pcs_vpc_cidr" {
  default = ""
  type = "string"
}

# Peering to PSS VPC
variable "pss_vpc_peering_id" {
  default = ""
  type = "string"
}
variable "pss_vpc_cidr" {
  default = ""
  type = "string"
}

variable "default_tags" {
  description = "Default tag values to be applied to all resources"
  type = "map"
}

variable "s3endpoint" {
  description = "VPC S3 edpoint id"
  default = ""
}

variable "static_routes" {
  description = "Stack route back to VPN gateways if propagation is wrong"
  default = ""
}