# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Vault - bootstrap

# These four variables are the primary key for a particular set of configuration
# values, pulled from Consul. They are also used in generating resource names
# and tag values.
variable "org" {
  description = "Organization or Business Unit"
}

variable "environment" {
  description = "SDLC environment"
}

variable "tier" {
  description = "The security tier for this stack (t1 for production-level, t2 for others)"
  default="t1"
}

variable "region" {
  description = "Region to use when launching"
}

# This variable cannot yet be put into Consul because of a Terraform limitation
# that a map variable type cannot be constructed from a string drawn from an external
# data source (Consul in this case).
variable "default_tags" {
  description = "tags"
  type        = "map"
}

variable "ami" {}
variable "deploymentserver_ip" {}
variable "instance_type" {}
variable "elb_internal" {}
variable "searchhead_count" {}
variable "indexer_count" {}
variable "indexer_volume_size" {}
variable "pass4SymmKey" {}
variable "secret" {}
variable "ui_password" {}

