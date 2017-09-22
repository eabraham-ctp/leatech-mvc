# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Vault - bootstrap

variable "region" {
  description = "The AWS region"
}

# Connection information for provisioning
variable "conn_key_name" {
  description = "The AWS key name to enable for login to the server for provisioning"
}

variable "conn_user_key" {
  description = "The private key corresponding to conn_key_name used for server provisioning"
}

variable "default_tags" {
  description = "Default tag values to be applied to all resources"
  type        = "map"
}

variable "environment" {
  description = "The SDLC environment"
}

variable "org" {
  description = "Organization / Business Unit"
}

variable "cluster_name" {
  description = "Name of the vault cluster"
}

variable "ssh_cidrs" {
  type = "list"
  description = "Cidr blocks for SSH access"
}

variable "os" {
  description = "Name of the OS to use when spinning up instances ex ubuntu1604x64"
}

variable "ami_id" {
  description = "Encrypted AMI ID"
}

variable "squid_elb_address" {
  description = "Internally generated address:port of the squid ELB"
  default = "no-proxy"
}

variable "squid_elb_sg" {
  description = "Squid ELB security group"
}

variable "no_proxy" {
  description = "A comma delmited string of things not to proxy"
  default = "169.254.169.254,localhost"
}
