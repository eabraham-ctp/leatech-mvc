# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Chef - bootstrap

variable "region" {
  description = "The AWS region"
}

# Base image and connection information for provisioning
variable "ami_id" {
  description = "The AMI to use"
}

variable "default_tags" {
  description = "Default tag values to be applied to all resources"
  type = "map"
}

# Chef server variables
variable "chef_name" {
  description = "A descriptive name for the Chef Server"
}

variable "instance_type" {
  description = "Instance Type"
}

variable "environment" {
  description = "The SDLC environment"
}

variable "org" {
  description = "Name of organization"
}

variable "os" {
  description = "The OS for the base AMI - allowed values are ubuntu1604x64 and rhel73x64"
  default = "rhel73x64"
}

variable "no_proxy" {
  description = "A comma delmited string of things not to proxy"
  default = "169.254.169.254,localhost"
}
