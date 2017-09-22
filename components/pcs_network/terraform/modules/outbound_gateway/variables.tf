#--------------------------------------------------------------
# This module creates subnets and resources necessary for
# creating Outbound Security Gateway infrastructure
#--------------------------------------------------------------

variable "vpc_id" {
  type = "string"
}
variable "vpc_name" {
  type = "string"
}
variable "azs" {
  type = "list"
}
variable "vpc_cidr" {
  type = "string"
}
variable "cidr_newbits" {
  type = "string"
}
variable "cidr_network_start" {
  type = "string"
}
variable "vpn_vgw" {
  type = "string"
}
variable "ecs_vpc_peering_id" {
  type = "string"
}
variable "ecs_vpc_cidr" {
  type = "string"
}
variable "scs_vpc_peering_id" {
  type = "string"
}
variable "scs_vpc_cidr" {
  type = "string"
}
variable "igw_id" {
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
variable "nat_gateway_ids" {
  type = "list"
}
