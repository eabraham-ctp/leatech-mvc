# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Consul Dataload - bootstrap
# Loads the configuraiton paramters in to Consul
#

variable "region" {
  description = "Region to use when launching"
}

variable "org" {
  description = "Organization or Business Unit"
}

variable "group" {
  description = "group or Business Unit"
}

variable "environment" {
  description = "SDLC environment"
}

variable "os" {
  description = "Name of the OS to use when spinning up instances ex ubuntu1604x64"
}

variable "default_tags" {
  description = "tags"
  type        = "map"
}

variable "conn_key_name" {
  description = "The AWS key name to enable for login to the server for provisioning"
}

variable "conn_private_key" {
  description = "The local path to the SSH private key"
}

variable "vault_cluster_name" {
  description = "Name of the vault cluster"
  default     = "vault_cluster_name"
}

variable "chef_instance_type" {
  description = "The Chef EC2 instance type"
  default     = "m4.large"
}

variable "artifactory_instance_type" {
  description = "The Artifactory EC2 instance type"
  default     = "m4.large"
}

variable "jenkins_instance_type" {
  description = "The Jenkins EC2 instance type"
  default     = "m4.large"
}

variable "vault_instance_type" {
  description = "The Vault EC2 instance type"
  default     = "m4.large"
}

variable "gitlab_instance_type" {
  description = "The GitLab EC2 instance type"
  default     = "m4.large"
}

variable "directory_password" {
  description = "The Active Directory Password"
  default     = "dem0p4ssword!"
}

variable "dhcp_domain_name" {
  description = "The DHCP Domain Name"
  default     = "domain.internal"
}

# OpenVPN security used to by modules security groups to give access to clients
variable "openvpn_sg" {
    description = "OpenVPN security group id."
}

variable "ami_id" {
  type = "string"
}