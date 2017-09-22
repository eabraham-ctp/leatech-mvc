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

variable "dmz_subnet_ids" {
  description = "The ID of the public subnets to host the services"
  type        = "list"
}

variable "default_tags" {
  description = "Default tag values to be applied to all resources"
  type = "map"
}

variable "squid_port" {
  default = "8080"
}

variable "ec2_squid_instance_type" {
  default = "t2.medium"
}

variable "conn_key_name" {
  description = "Name of the SSH keypair to use in AWS."
}
variable "ami_id" {}
variable "vpc_cidr" {}
variable "backend_bucket_name" {}
variable "squid_conf_prefix" {
  default = "squid_config"
}

variable "common_sg" {
  description = "Common Security Group "
}

variable "ssh_sg" {
  description = "SSH Security Group "
}

variable "squid_egress_ports" {
  description = "List of egress ports for the squid instance  to CIDR's (80,443 a minimum)"
  type        = "list"
  default     = ["0.0.0.0/0|80","0.0.0.0/0|443"]
}
