# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Trend Server Marketplace - Variables File
#
# Module for creating the Trend Deep Scan Serverfor Platform Common Services (PCS). This version uses
# Terraform scripts and Marketplace AMI

variable "region" { 
  description = "Region to execute/build in"
}

variable "group" {
  description = "SDLC Group"
}

variable "tm_ami_id" {
  description = "The ami id which will used when creating the server"
}

variable "instance_type" {
   description = "Instance Type"
}

variable "vpc_id" {
   description = "The VPC ID of the VPC the Trend Server will be operating"
}

variable "vpc_cidr" {
	description = "CIDR block of VPC"
}

 variable "security_subnet_ids" {
   description = "VPC Security Subnet id"
   type = "list"
 }

 variable "data_subnet_ids" {
   description = "VPC Security Subnet id"
   type = "list"
 }

# variable "allowed_ips" {
#   description = "IP's allowed"
# }

variable "default_tags" {
  description = "Default tag values to be applied to all resources"
  type        = "map"
}

variable "conn_key_name" {
   description = "Key Pair to use for provisioning"
}

variable "environment" {
  description = "The SDLC environment"
}

variable "org" {
  description = "Name of organization"
}

variable "dsm_db_engine" { 
  description = "database engine"
}

variable "dsm_db_type" { 
  description = "database type"
}

variable "dsm_db_instance_type" { 
  description = "rds instance sizing"
}

variable "dsm_db_instance_name" { 
  description = "rds database instance name"
}

variable "dsm_db_username" { 
  description = "database username"
}

variable "dsm_db_password" { 
  description = "database password"
}

variable "dsm_username" {
  description = "username for DSM Console"
}

variable "dsm_password" {
  description = "pasword for dsm_user"
}

variable "dsm_managerport" {
  description = "DSM server management port, usually 443"
}

variable "dsm_heartbeatport" {
    description = "DSM heardbeat port, usualy 4120"
}

variable "squid_elb_address" {
  description = "squid ELB address for setting proxy"
}

variable "general_kms" {
  description = "KMS Key for encrypting"
}

variable "zone_id" {
  description = "zone ID for creating CNAME"
}

variable "squid_elb_sg" {
  description = "sg for egress to squid"

}

variable "common_sg" {
  description = "sg for common access"

}

variable "openvpn_sg" {
  description = "sg for common access"
  default = ""
}

variable "elb_health_check_target" {
  description = "url for ELB health check"
  default     = "HTTPS:443/rest/status/manager/ping"
}

variable "elb_healthy_threshold" {
  description = "The number of checks before the instance is declared healthy."
  default = "3"
}

variable "elb_unhealthy_threshold" {
  description = "The number of checks before the instance is declared unhealthy."
  default = "5"
}

variable "elb_timeout" {
  description = "The length of time before the check times out."
   default = "5"
}                  

variable "elb_health_check_interval" { 
  description = "The interval between checks."
  default     = "30"
} 

variable "vpc_security_group_ids" {
  description = "List of security groups to attach to instance"
  type        = "list"
}
