# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Common network modules
# Subnets - DMZ

variable "vpc_name" {
  description = "The base VPC name, such as PCS-Prod-USE1"
  type = "string"
}

variable "org" {
  description = "Organization / Business Unit"
}

variable "environment" {
  description = "SDLC environment"
}

variable "saml_provider" {
  description = "An optional SAML provider for federated IAM roles, format arn:aws:iam::<AWS-account-ID>:saml-provider/<provider-name>"
  default = ""
  type = "string"
}

variable "vpc_id" {
  description = "The VPC in which to create the DMZ subnets"
  type = "string"
}

variable "azs" {
  description = "The availbility zones in which to place the DMZ subnets"
  type = "list"
}

variable "subnet_cidrs" {
  type = "list"
}

variable "default_tags" {
  description = "Default tag values to be applied to all resources"
  type = "map"
}

variable "subnet_name" {
  description = "Subnet name"
}

variable "vpn_vgw_ids" {
  description = "The IDs of any VPN gateways for the VPC, for route propagation"
  type = "list"
}

variable "s3endpoint" {
  description = "VPC S3 edpoint id"
  default = ""
}