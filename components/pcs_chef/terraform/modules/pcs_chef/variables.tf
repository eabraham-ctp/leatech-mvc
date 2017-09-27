
variable "vpc_id" {
  description = "The VPC ID of the VPC the Chef Server will be operating"
}

variable "subnet_ids" {
  description = "VPC Subnet ids"
}

variable "ami_id" {
  description = "Base AMI to build server"
}

variable "instance_type" {
  description = "Instance Type"
}

variable "default_tags" {
  description = "Default tag values to be applied to all resources"
  type = "map"
}

variable "base_dn" {
  description = "Base DN for Directory Configuration"
}

variable "bind_dn" {
  description = "Bind DN for Directory Configuration"
}

variable "bind_secret" {
  description = "Bind Secret for Directory Configuration"
}

variable "login_attribute" {
  description = "Login Attribute used for directory, defaults to sAMAccountName for Active Directory"
  default = "sAMAccountName"
}

variable "ldap_host" {
  description = "LDAP Host"
}

variable "ldap_port" {
  description = "LDAP Port"
}

variable "environment" {
  description = "The SDLC environment"
}

variable "org" {
  description = "Name of organization"
}
variable "group" {
  description = "Business group"
}
# Fixing Chef deployment missing vars

variable "conn_user_name" {
  description = "The username for making an SSH connection to the server, as required by the AMI"
}

variable "conn_key_name" {
  description = "The AWS key name to enable for login to the server for provisioning"
}

variable "conn_private_key" {
  description = "The private key file corresponding to conn_key_name used for server provisioning"
}

variable "squid_elb_address" {
  description = "Internally generated address:port of the squid ELB"
  default     = "no-proxy"
}

variable "no_proxy" {
  description = "A comma delmited string of things not to proxy"
  default = "169.254.169.254,localhost"
}

variable "common_sg" {
  description = "Common Security Group "
}

variable "ssh_sg" {
  description = "SSH Security Group "
}

variable "vpc_security_group_ids" {
  description = "List of security groups to attach to instance"
  type        = "list"
}

variable "vpc_cidr" {}

variable "install_url" {}

variable "hostname" {}

variable "admin_username" {}

variable "admin_password" {}

variable "admin_firstname" {}

variable "admin_lastname" {}

variable "email_address" {}

variable "openvpn_enabled" {}

variable "openvpn_sg" {}

variable "route53_zone_id" {
  default = ""
}