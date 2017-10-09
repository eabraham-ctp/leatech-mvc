variable "region" {
  description = "The AWS region"
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

variable "default_tags" {
  description = "Default tag values to be applied to all resources"
  type        = "map"
}

variable "consul_sg_ids" {
  description = "List of Consul security groups IDs to grant access to"
  type        = "list"

}

variable "vault_sg_ids" {
  description = "List of Vault security groups IDs to grant access to"
  type        = "list"
}

variable "ssh_sg_ids" {
  description = "List of SSH security groups IDs to grant access to"
  type        = "list"
}

variable "s3_endpoint_prefix_id" {
  description = "[Optional] - S3 VPC endpoint prefix ID"
  type        = ""
}