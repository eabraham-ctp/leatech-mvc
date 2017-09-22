# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services

variable "region" {
  description = "The AWS region"
}

# Connection information for provisioning
variable "conn_key_name" {
  description = "The AWS key name to enable for login to the server for provisioning"
}

variable "conn_user_key" {
  description = "The private key corresponding to conn_key_name used for server provisioning"
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

#RDS
variable "rds_allocated_storage" {
  default = 10
}
variable "db_name" {
}
variable "db_username" {
  default = "dbadmin"
}
variable "db_password" {
}
variable "storage_type" {
  default = "gp2"
}
variable "db_identifier" {
}
variable "db_instance_type" {
  default = "db.t2.small"
}

variable "multi_az" {
  default = false
}

variable "db_backups" {
  default = 0
}
variable "skip_final_snapshot" {
  default = true
}
variable "copy_tags_to_snapshot" {
  default = true
}

variable "no_proxy" {
  description = "A comma delmited string of things not to proxy"
  default = "localhost,169.254.169.254"
}

variable "ssh_cidrs" {
  type = "list"

  description = "Cidr blocks for SSH access"
}

variable "general_kms" {
}

# APP and Instances

#TECHDEBT we shouldn't have fat images
variable "rstudio_ami_id" {
}

variable "rstudio_instance_type" {
}


variable "app_name" {
  default = "rstudio_poc"
}

variable "workstation_sg" {
}

# Rstudio
variable "rstudio_map" {
  description = "Map to create security rules with from between workstation_and app_stack from_port,to_port,protocol"
  type        = "list"
  default     = ["22|22|TCP","8787|8787|TCP","3838|3838|TCP"]
}

variable "iam_instance_profile" {
  description = "(Optional) The IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile. "
}
