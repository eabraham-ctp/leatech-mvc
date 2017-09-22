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
variable "allocated_storage" {
  default = 10
}
variable "db_name" {
}
variable "db_username" {
  default = "dbadmin"
}
variable "db_password" {
  default = ""
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
  default = ""
}

# APP and Instances


#TECHDEBT we shouldn't have fat images
variable "talend_ami_id" {
}

variable "talend_instance_type" {
}

variable "app_name" {
  default = "Talend"
}

variable "workstation_sg" {
}

# Talend
variable "talend_map" {
  description = "Map to create security rules with from between workstation_and app_stack from_port,to_port,protocol"
  type        = "list"
  default     = ["80|80|TCP","81|82|TCP","1099|1100|TCP","2181|2181|TCP","3334|5333|TCP","3389|3389|TCP","5439|5439|TCP","5601|5601|TCP","8000|8009|TCP","8010|8010|TCP","8040|8042|TCP","8050|8050|TCP","8052|8052|TCP","8053|8054|TCP","8055|8055|TCP","8080|8081|TCP","8098|8098|TCP","8099|8099|TCP","8101|8102|TCP","8187|8187|TCP","8443|8443|TCP","8580|8580|TCP","8888|8889|TCP","8898|8898|TCP","8989|8989|TCP","9001|9003|TCP","9060|9060|TCP","9080|9080|TCP","9092|9092|TCP","9200|9200|TCP","9998|9998|TCP","9999|9999|TCP","11480|11480|TCP","19924|19924|TCP","19928|19928|TCP","19999|19999|TCP","27017|27017|TCP","44444|44445|TCP"]

}
variable "talend_iam_instance_profile" {
  description = "(Optional) The IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile. "
}

