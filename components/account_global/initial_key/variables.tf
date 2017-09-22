# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# One time init resources
#

variable "region" {
   description = "The AWS region"
}

variable "conn_key_name" {
  description = "The AWS key name to enable for login to the server for provisioning"
}

variable "conn_public_key" {
  description = "The public key corresponding to conn_key_name used for server provisioning"
}
