##################################################################
# Security Common Services(SCS) VPC Variables
# see scs_vpc.tf for more details

variable "vpc_name" {
  type = "string"
}
variable "vpc_cidr_block" {
  type = "string"
}
variable "vpn_vgw_id" {
  type = "string"
}
variable "environment" {
  type = "string"
}
variable "lifecycle" {
  type = "string"
}
variable "contact" {
  type = "string"
}
variable "domain_name_servers" {
  type = "list"
}
variable "domain" {
  type = "string"
}