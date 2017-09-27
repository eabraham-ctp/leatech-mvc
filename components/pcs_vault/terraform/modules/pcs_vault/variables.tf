# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Consul

variable "vpc_name" {
  description = "The full name of the hosting VPC (used in naming and tagging resources)"
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
  default     = "m4.large"
}

variable "subnet_id" {
  description = "The ID of a subnets for the primary Vault server (typically one per AZ)"

}

variable "default_tags" {
  description = "Default tag values to be applied to all resources"
  type        = "map"
}

variable "chef_node_name" {
  description = "The node name to register with the Chef server"
  default     = ""
}

variable "chef_server_url" {
  description = "The URL to the Chef server; if empty, will execute Chef Solo with cookboks retrieved with git_key_path"
  default     = ""
}

variable "chef_version" {
  description = "The Chef version to install"
  default     = "13.0.118"
}

variable "chef_user" {
  default = ""
}

variable "chef_key" {
  default = ""
}

variable "consul_address" {
  description = "IP address and Port for the Consul server"
}

variable "consul_data_center" {
  description = "Consul datacenter"
}

variable "environment" {
  description = "The SDLC environment"
}

variable "org" {
  description = "Organization / Business Unit"
}

variable "os" {
  description = "Name of the OS to use when spinning up instances ex ubuntu1604x64"
}

variable "ssh_cidrs" {
  type = "list"
  description = "Cidr blocks for SSH access"
}

variable "cluster_name" {
  description = "Name of the vault cluster"
}

variable "consul_agent_sg_id" {
  description = "ID of the Consul agent security group"
}

variable "consul_cluster_sg_id" {
  description = "ID of the Consul Cluster security group"
}

variable "ami_id" {
  description = "Encrypted AMI ID"
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
  default = "169.254.169.254,localhost"
}

# OpenVPN security used to by modules security groups to give access to clients
variable "openvpn_sg" {
    description = "OpenVPN security group id."
}

variable "common_sg" {
  description = "Common Security Group "
}

variable "ssh_sg" {
  description = "SSH Security Group "
}

variable "vpc_cidr" {}

variable "vpc_security_group_ids" {
  description = "List of security groups to attach to instance"
  type        = "list"
}

variable "route53_zone_id" {
  default = ""
}
