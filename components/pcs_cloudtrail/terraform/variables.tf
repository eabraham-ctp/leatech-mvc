# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Cloudtrail

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

variable "default_tags" {
  description = "tags"
  type        = "map"
  default     = {}
}

variable "kms_key" {}
variable "ct_account_numbers" {type = "list"}
variable "ct_accounts" {type = "list"}
variable "ct_account_name" {}
variable "ct_trails" {type = "list"}
variable "force_destroy" {}
variable "versioning" {}
variable "app" {}
