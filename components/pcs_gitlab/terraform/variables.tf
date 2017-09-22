# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# GitLab

variable "region" {
  description = "The AWS region"
}

variable "environment" {
  description = "The SDLC environment"
}

variable "org" {
  description = "Organization / Business Unit"
}

variable "default_tags" {
  description = "Default tag values to be applied to all resources"
  type = "map"
}

variable "ami_id" {
  description = "Base AMI to build server"
}

variable "hostname" {
  default = ""
}
variable "chef_user_name" {
  default = ""
}
variable "chef_user_key" {
  default = ""
}
variable "private_domain" {
  default = ""
}
# variable "base_dn" {
#   description = "Base DN for Directory Configuration"
# }

# variable "bind_dn" {
#   description = "Bind DN for Directory Configuration"
# }

# variable "bind_secret" {
#   description = "Bind Secret for Directory Configuration"
# }

# variable "login_attribute" {
#   description = "Login Attribute used for directory, defaults to sAMAccountName for Active Directory"
#   default = "sAMAccountName"
# }

# variable "ldap_host" {
#   description = "LDAP Host"
# }

# variable "ldap_port" {
#   description = "LDAP Port"
# }

variable "gitlab_version" {
  default     = "9.5.5-ce.0.el7"
  description = "Version of gitlab  both the version and the release"
}

# variable "sumo_accesskey" {
#   description = "Sumologic Access Key"
# }

# variable "sumo_accessid" {
#   description = "Sumologic Access ID"
# }