# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services

variable "region" {
  description = "The AWS region"
  default = "eu-west-1"
}

variable "default_tags" {
  description = "Default tag values to be applied to all resources"
  type        = "map"
}

variable "environment" {
  description = "The SDLC environment"
}

variable "org" {
  description = "Organization / Business Unit"
}

variable "allocated_storage" {
  default = 10
}
variable "db_name" {
}
variable "db_identifier" {
}
variable "username" {
  default = "dbadmin"
}
variable "password" {
}
variable "storage_type" {
  default = "gp2"
}
variable "instance_type" {
}
variable "subnet_ids" {
  type = "list"
}
variable "multi_az" {
  default = false
}
variable "general_kms" {
}
variable "db_backups" {
  default = 0
}
variable "engine" {
  default = "postgres"
}
variable "skip_final_snapshot" {
  default = true
}
variable "copy_tags_to_snapshot" {
  default = true
}

variable "app_name" {
}

variable "vpc_id" {
}

variable "storage_encrypted" {
}

variable "app_sg" {
}
