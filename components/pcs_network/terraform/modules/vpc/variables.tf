# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Common Terraform Modules
# VPC


variable "vpc_name" {
  description = "The full name of the VPC"
  type = "string"
}

variable "environment" {
  description = "The SDLC environment"
}

variable "org" {
  description = "Organization / Business Unit"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type = "string"
}

variable "attach_vpn_gateway" {
  description = "Boolean flag on whether or not to attach the a VPN gateway (defined by vpn_vgw_id)"
  type = "string"
}

variable "vpn_vgw_id" {
  description = "The ID for the VPN gateway to be attached; if zero-length, no gateway will be attached"
  type = "string"
}

variable "domain_name_servers" {
  description = "A list of on-premise domain name server addresses to include in DHCP"
  type = "list"
}

variable "domain" {
  description = "The domain associated with the domain_name_servers"
  type = "string"
}

variable "default_tags" {
  description = "Default tag values to be applied to all resources"
  type = "map"
}
