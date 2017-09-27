# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# artifactory

variable "vpc_name" {
  description = "The full name of the hosting VPC (used in naming and tagging resources)"
}

variable "region" {
  description = "The AWS region"
}

variable "ami_id" {
  description = "The AMI to use"
  default = ""  
}

variable "instance_type" {
  description = "The EC2 instance type"
  default = "t2.medium"
}

variable "bootstrap" {
  description = "Boolean to indicate whether to bootstrap the artifactory cluster from this node"
  default = false
}

variable "default_tags" {
  description = "Default tag values to be applied to all resources"
  type = "map"
}

variable "chef_version" {
  description = "The Chef version to install"
  default = "13.0.118"
}
variable "hostname" {
  default = ""
}
variable "chef_user_name" {
  default = ""
}
variable "chef_user_key" {
  default = ""
}
variable "private_domain" {
  default = ""
}
variable "environment" {
  description = "The SDLC environment"
}

variable "org" {
  description = "Name of organization"
}