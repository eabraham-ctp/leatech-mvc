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

variable "ami_id" {
  description = "Encrypted AMI ID"
}


variable "vpc_id" {
  description = "The VPC which will host the server"
}

variable "conn_key_name" {
  description = "The AWS key name to enable for login to the server for provisioning"
}

variable "conn_user_key" {
  description = "The private key corresponding to conn_key_name used for server provisioning"
}

variable "instance_type" {
  description = "The EC2 instance type"
}

variable "subnet_id" {
  description = "The ID of a subnets for the primary Vault server (typically one per AZ)"

}

variable "squid_elb_address" {
  description = "Internally generated address:port of the squid ELB"
  default     = "no-proxy"
}

variable "squid_elb_sg" {
  description = "Squid ELB security group"
}
variable "no_proxy" {
  description = "A comma delmited string of things not to proxy"
  default = "localhost,169.254.169.254"
}

variable "app_name" {
}

variable "rds_sg" {
  default = ""
}

variable "rds_port" {
}

variable "workstation_sg" {
}

variable "sg_map" {
  description = "List to create security rules with from between workstation_and app_stack from_port,to_port,protocol"
  type        = "list"
}

variable "iam_instance_profile" {
  description = "(Optional) The IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile. "
  default     = ""
}


variable "vpc_security_group_ids" {
  description = "List of security groups to attach to instance"
  type        = "list"
}

variable "s3_endpoint_prefix_id" {
  description = "[Optional] - S3 VPC endpoint prefix ID"
  type        = ""
}
