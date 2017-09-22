# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# GitLab


variable "vpc_id" {
  description = "The VPC which will host the server"
}

variable "ami_id" {
  description = "The ami id which will used when creating the server"
}

variable "instance_type" {
  description = "The EC2 instance type"
}
variable "subnet_ids" {
  description = "The ID of a subnets for the primary Gitlab server (typically one per AZ)"
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

variable "chef_user_name" {
  default = ""
}

variable "chef_user_key" {
  default = ""
}

variable "git_key_path" {
  description = "A path to the Git key used to download the cookbooks if using Chef Solo; only used if chef_server_url is empty"
  default     = ""
}
variable "group" {
  description = "Business group"
}

variable "environment" {
  description = "The SDLC environment"
}

variable "org" {
  description = "Organization / Business Unit"
}


variable "hostname" {
  default = ""
}


variable "base_dn" {
  description = "Base DN for Directory Configuration"
}

variable "bind_dn" {
  description = "Bind DN for Directory Configuration"
}

variable "bind_secret" {
  description = "Bind Secret for Directory Configuration"
}

variable "login_attribute" {
  description = "Login Attribute used for directory, defaults to sAMAccountName for Active Directory"
  default = "sAMAccountName"
}

variable "ldap_host" {
  description = "LDAP Host"
}

variable "ldap_port" {
  description = "LDAP Port"
}

variable "gitlab_version" {
  default     = "9.3.5"
  description = "Version of gitlab ie 9.3.5"
}

variable "squid_elb_address" {
  description = "Internally generated address:port of the squid ELB"
  default     = "no-proxy"
}

variable "no_proxy" {
  description = "A comma delmited string of things not to proxy"
  default = "169.254.169.254,localhost"
}

variable "common_sg" {
  description = "Common Security Group "
}

variable "ssh_sg" {
  description = "SSH Security Group "
}

variable "vpc_security_group_ids" {
  description = "List of security groups to attach to instance"
  type        = "list"
}

variable "conn_user_name" {
  description = "The username for making an SSH connection to the server, as required by the AMI"
}

variable "conn_key_name" {
  description = "The AWS key name to enable for login to the server for provisioning"
}

variable "conn_private_key" {
  description = "The private key file corresponding to conn_key_name used for server provisioning"
}

variable "vpc_cidr" {}


variable "consul_address" {
  default = ""
}
variable "consul_data_center" {
  default = ""  
}

variable "http_proxy" {
  default = ""  
}

variable "https_proxy" {
  default = ""  
}

variable "private_domain" {
  default = ""
}

# variable "sumo_accesskey" {
#   description = "Sumologic Access Key"
# }

# variable "sumo_accessid" {
#   description = "Sumologic Access ID"
# }