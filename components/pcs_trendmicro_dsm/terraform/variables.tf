# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Trend Server Marketplace - Variables File
#
# Module for creating the Trend Deep Scan Serverfor Platform Common Services (PCS). This version uses
# Terraform scripts and Marketplace AMI


variable "org" {
  description = "organization for naming / tagging"
}

variable "group" {
  description = "group for naming / tagging"
}

variable "environment" {
  description = "environment for naming / tagging"
}

variable "region" {
  description = "region for environment provisioning"
}

#TECHDEBT - descriptions need to be added to these variables

variable "tm_ami_id" {
  description = "The ami id which will used when creating the server"
}

variable "tm_instance_type" {
  description = "The ami id which will used when creating the server"
  default     = "m4.xlarge"
}

variable "kms_general_key" {
  description = "KMS key to encrypt RDS"
}

variable "default_tags" {
  description = "Default tag values to be applied to all resources"
  type        = "map"
  default     = {
                  ApplicationName   = "TrendMicro"
                  TechnicalResource = "Jeff.Dickman@cloudtp.com"
                  BusinessOwner     = "Kacy.Clarke@cloudtp.com"
  }
}

variable "dsm_db_engine" { 
  description = "database engine type"
  default     = "postgres"
}

variable "dsm_db_type" { 
  description = "database type"
  default     = "PostgreSQL"
}

variable "dsm_db_instance_type" { 
  description = "rds instance size"
  default     = "db.m4.xlarge"
}

variable "dsm_db_instance_name" { 
  description = "rds database instance name, internal to postrges"
  default     = "trendmicro_dsm"
}

variable "dsm_db_username" { 
  description = "database username"
  default     = "DSMMaster"
}

variable "dsm_db_password" { 
  description = "database password"
  default     = "Welcome123!"
}

variable "dsm_username" {
  description = "username for DSM Console"
  default     = "admin"
}

variable "dsm_password" {
  description = "pasword for dsm_user"
  default     = "Welcome123!"
}

variable "dsm_managerport" {
  description = "DSM server management port, usually 443"
  default     = "443"
}

variable "dsm_heartbeatport" {
  description = "DSM heardbeat port, usualy 4120"
  default     = "4120"
}

variable "health_check_target" {
  description = "url for ELB health check"
  default     = "HTTPS:443/rest/status/manager/ping"
}

variable "elb_healthy_threshold" {
  description = "The number of checks before the instance is declared healthy."
  default     = "3"
}

variable "elb_unhealthy_threshold" {
  description = "The number of checks before the instance is declared unhealthy."
  default     = "5"
}

variable "elb_timeout" {
  description = "The length of time before the check times out."
   default    = "5"
}      

variable "elb_health_check_interval" { 
  description = "The interval between checks."
  default     = "30"
}            
