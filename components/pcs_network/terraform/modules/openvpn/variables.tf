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

variable "default_tags" {
  description = "Map of default tag values for all resources"
  type        = "map"
  default     = {}
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
 type = "string"
 description = "The elastic IP allocation ID"
}

#TECHDEBT deprecated near future
variable "vpc_cidr" {
}

variable "dmz_subnet_ids" {
  type = "list"

}

variable "vpc_id" {
}

variable "conn_key_name" {
  description = "The AWS key name to enable for login to the server for provisioning"
}

variable "vpc_security_group_ids" {
  description = "List of security groups to attach to instance"
  type        = "list"
}
