# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Jenkins - Variables
#
# Module for creating the Jenkins Service for Platform Common Services (PCS). This version uses
# Chef cookbooks on top of the Terraform scripts

variable "name" {
  description = "The name of the Jenkins service"
}

variable "vpc_id" {
  description = "The VPC to host the Jenkins server"
}

variable "allowed_ips" {
  description = "CIDR block of addresses allowed to access Jenkins"
}

variable "subnet_ids" {
  description = "The allowed subnets for the Jenkins servers"
  type = "list"
}

variable "default_tags" {
  description = "Default tag values to be applied to all resources"
  type = "map"
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
  description = "The EC2 instance type for the Jenkins master"
}

variable "chef_server_ip" {
}

variable "artifactory_server_ip" {
}

variable "node_name" {
  description = "The "
}

variable "chef_server_url" {
  description = "The URL (including org) of the Chef server"
}

variable "chef_user_name" {
  description = "The Chef user for provisioning"
}

variable "chef_user_key" {
  description = "The Chef user key for provisioning"
}

variable "version" {
  default = "13.0.118"
}

variable "ad_servers" {
  description = "List of IP addresses for the Active Directory controllers"
  type = "list"
}

variable "ad_domain" {
  description = "The Active Directory domain"
}

variable "environment" {
  description = "SDLC environment"
}

variable "org" {
  description = "Organization or business unit"
}
