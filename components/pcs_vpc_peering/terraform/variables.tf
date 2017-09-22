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

variable "vpc_id" {
  description = "The ID of the VPC to host the services"
}

variable "peer_vpc_id" {
  description = "The ID of the VPC to host the services"
}

variable "default_tags" {
  type = "map"
  description = "Default tag values to be applied to all resources"
  default ={
    TEST = "TRUE"
  }
}

variable "vpcpeer_accepter_acct_id" {
  type = "string"
  description = "Account ID of the accepter VPC"
}

variable "vpcpeer_accepter_profile" {
  type = "string"
  description = "Accepter VPC"
  }

variable "vpcpeer_accepter_vpc_cidr" {
  type = "string"
}

variable "aws_profile" {
  type = "string"
}

variable allow_remote_vpc_dns_resolution {
  default = true
}