# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services

# variable "vpc_name" {
#   description = "The full name of the VPC"
# }

# variable "environment" {
#   description = "The SDLC environment"
# }

variable "org" {
  description = "Name of organization"
}

variable "region" {
  description = "The AWS region"
}

variable "environment" {
  description = "SDLC environment"
}

variable "default_tags" {
  type = "map"
  description = "Default tag values to be applied to all resources"
}

variable "kms_description" {
  type = "string"
  description = "kms key description"
  default = "Base AMI Encryption Key"
}

variable "kms_name" {
  type = "string"
  description = "describe your variable"
  default = "BaseAMI"
}
