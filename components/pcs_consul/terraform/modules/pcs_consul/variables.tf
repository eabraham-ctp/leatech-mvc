# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Consul

variable "vpc_name" {
  description = "The full name of the hosting VPC (used in naming and tagging resources)"
}

variable "vpc_id" {
  description = "The VPC which will host the server"
}

variable "environment" {
  description = "SDLC environment"
}

variable "org" {
  description = "Organization or business unit"
}

variable "conn_key_name" {
  description = "The AWS key name to enable for login to the server for provisioning"
}

variable "conn_user_key" {
  description = "The private key corresponding to conn_key_name used for server provisioning"
}

variable "conn_private_key" {
  description = "The private key file corresponding to conn_key_name used for server provisioning"
}

variable "instance_type" {
  description = "The EC2 instance type"
  default     = "m4.large"
}

variable "subnet_ids" {
  description = "The IDs of all available subnets for the server (typically one per AZ)"
  type        = "list"
}

variable "bootstrap" {
  description = "Boolean to indicate whether to bootstrap the Consul cluster from this node"
  default     = false
}

variable "default_tags" {
  description = "Default tag values to be applied to all resources"
  type        = "map"
}

variable "chef_node_name" {
  description = "The node name to register with the Chef server"
  default     = ""
}

variable "chef_server_url" {
  description = "The URL to the Chef server; if empty, will execute Chef Solo with cookboks retrieved with git_key_path"
  default     = ""
}

variable "chef_version" {
  description = "The Chef version to install"
  default     = "13.0.118"
}

variable "chef_user" {
  default = ""
}

variable "route53_zone_id" {
  default = ""
}
variable "chef_key" {
  default = ""
}

variable "git_key_path" {
  description = "A path to the Git key used to download the cookbooks if using Chef Solo; only used if chef_server_url is empty"
  default     = ""
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

variable "sec_service_sg" {
  description = "Security Services Security Group "
}

variable "ssh_sg" {
  description = "SSH Security Group "
}

variable "no_proxy" {
  description = "A comma delmited string of things not to proxy"
  default = "169.254.169.254,localhost"
}

variable "vpc_security_group_ids" {
  description = "List of security groups to attach to instance"
  type        = "list"
}

variable "vpc_cidr" {}
