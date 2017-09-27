# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Consul - bootstrap

variable "vpc_name" {
  description = "The full name of the VPC to host the services"
}

variable "org" {
  description = "Organization or Business Unit"
}

variable "environment" {
  description = "SDLC environment"
}

variable "vpc_id" {
  description = "The ID of the VPC to host the services"
}

variable "region" {
  description = "The AWS region"
}

variable "service_subnet_ids" {
  description = "The ID of the subnet to host the services"
  type = "list"
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

variable "default_tags" {
  description = "tags"
  type="map"
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

variable "no_proxy" {
  description = "A comma delmited string of things not to proxy"
  default = "169.254.169.254,localhost"
}

variable "common_sg" {
  description = "Common Security Group "
}
variable "sec_service_sg" {
  description = "Security Services Security Group "
}
variable "ssh_sg" {
  description = "SSH Security Group "
}

variable "vpc_cidr" {}

variable "route53_zone_id" {
  default = ""
}