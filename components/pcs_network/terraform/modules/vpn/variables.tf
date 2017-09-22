# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Common network modules
# VPN

variable "org" {
  description = "Organization or business unit"
}

variable "environment" {
  description = "SDLC environment"
}

variable "vpn_conn_config" {
  description = "VPN connection configurations (IP address and ASN); if empty, no VPN will be created"
  type        = "list"
  default     = []
}

variable "default_tags" {
  description = "Map of default tag values for all resources"
  type        = "map"
  default     = {}
}

variable "external_gw_id" {
  description = "A VPG that was created outside of the terraform process"
  default     = ""
}

variable "transit_vpc_spoke" {
  description = "Will this VPC connect to a transit VPC"
  type        = "string"
  default     = "false"
}

variable "vpc_id" {
  description = "The ID of the VPC to host the services"
}
