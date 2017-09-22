# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# artifactory

variable "vpc_name" {
  description = "The full name of the hosting VPC (used in naming and tagging resources)"
}

variable "vpc_id" {
  description = "The VPC which will host the server"
}

variable "ami_id" {
  description = "The AMI to use"
}

variable "conn_user_name" {
  description = "The username for making an SSH connection to the server, as required by the AMI"
}

variable "conn_key_name" {
  description = "The AWS key name to enable for login to the server for provisioning"
}

variable "conn_user_key" {
  description = "The private key corresponding to conn_key_name used for server provisioning"
}

variable "instance_type" {
  description = "The EC2 instance type"
  default = "t2.medium"
}

variable "subnet_ids" {
  description = "The IDs of all available subnets for the server (typically one per AZ)"
  type = "list"
}

variable "bootstrap" {
  description = "Boolean to indicate whether to bootstrap the artifactory cluster from this node"
  default = false
}

variable "default_tags" {
  description = "Default tag values to be applied to all resources"
  type = "map"
}

variable "chef_node_name" {
  description = "The node name to register with the Chef server"
}

variable "chef_server_url" {
  description = "The URL to the Chef server"
}

variable "chef_version" {
  description = "The Chef version to install"
  default = "13.0.118"
}

variable "chef_user" {
}

variable "chef_key" {
}

variable "environment" {
  description = "The SDLC environment"
}

variable "org" {
  description = "Name of organization"
}