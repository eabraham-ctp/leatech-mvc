# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# VPC (simple)

variable "vpc_name" {
  description = "The full name of the VPC"
}

variable "environment" {
  description = "The SDLC environment"
}

variable "org" {
  description = "Name of organization"
}

variable "region" {
  description = "The AWS region"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
}

variable "azs" {
  description = "The list of AZs which the VPC will span"
  type        = "list"
}

variable "subnet_cidrs" {
  description = "Map subnet names to comma-separated list of CIDR blocks"
  type = "map"
}

variable "default_tags" {
  description = "Default tag values to be applied to all resources"
  type        = "map"
}

variable "domain_name_servers" {
  description = "Any on-premise DNS servers that should be part of the VPC DHCP settings"
  type = "list"
}

# TODO need description
variable "domain" {
  description = ""
  type        = "string"
  default     = ""
}

# TODO this needs much better description
variable "saml_provider" {
  description = "The SAML provider for this VPC"
  type        = "string"
  default     = ""
}

# TODO this needs much better description
variable "vpn_conn_config" {
  description = "Configuration details (ASN and router IP addresses) for the VPN connection for this VPC"
  type        = "list"
}

# OpenVPN credentials
variable "openvpn_user" {
  description = "The user name for the OpenVPN admin account"
}

variable "openvpn_password" {
  description = "The password for the OpenVPN admin account"
}

variable "openvpn_ami" {
  description = "Optional AMI for OpenVPN, to use a licensed Marketplace version (if ommitted, will use the free version)"
  default = ""
}

variable "openvpn_eip" {
 type        = "string"
 description = "The elastic IP allocation ID"
 default     = ""
}

variable "services_subnets_name" {
  type = "string"
  default = "Services"
}

variable "ssh_cidrs" {
  type        = "list"
  description = "IP CIDR ranges allowed to ssh in"
}

variable "conn_key_name" {
  description = "The AWS key name to enable for login to the server for provisioning"
  default     = ""
}

variable "external_gw_id" {
  description = "A VPG that was created outside of the terraform process"
  default     = ""
}

variable "static_routes" {
  description = "Stack route back to VPN gateways if propagation is wrong"
  default     = ""
}

# Peering to PCS VPC used on a rerun to fix routes via peering
variable "pcs_vpc_peering_id" {
  default = ""
  type = "string"
}
variable "pcs_vpc_cidr" {
  default = ""
  type = "string"
}

# Peering to PSS VPC adds routing back to the requester VPC over peering GW
variable "pss_vpc_peering_id" {
  default = ""
  type = "string"
}
variable "pss_vpc_cidr" {
  default = ""
  type = "string"
}

variable "transit_vpc_spoke" {
  description = "Will this VPC connect to a transit VPC"
  type        = "string"
  default     = "false"
}
