##################################################################
# Inbound Web Application Firewall app & management variables
# see inbound_gateway.tf for more details

variable "vpc_id" {
}
variable "vpc_name" {
}
variable "azs" {
  type = "list"
}
variable "vpc_cidr" {
}
variable "cidr_newbits" {
}
variable "cidr_network_start" {
}
variable "vpn_vgw" {
}
variable "ecs_vpc_peering_id" {
}
variable "ecs_vpc_cidr" {
}
variable "scs_vpc_peering_id" {
}
variable "scs_vpc_cidr" {
}
variable "igw_id" {
}
variable "environment" {
}
variable "lifecycle" {
}
variable "contact" {
}
