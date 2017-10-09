# Read VPC state to find service subnet IDs
data "terraform_remote_state" "vpc" {
  backend = "consul"
  environment = "${terraform.env}"
  config {
    path = "aws/pcs/vpc/tfstate"
  }
}


data "terraform_remote_state" "squid" {
  backend     = "consul"
  environment = "${terraform.env}"
  config {
    path = "aws/pcs/squid/tfstate"
  }
}

# # Read the directory state to find the LDAP address, base DN and bind DN
# data "terraform_remote_state" "directory" {
#   backend = "consul"
#   environment = "${terraform.env}"
#   config {
#     path = "aws/pcs/directory/tfstate"
#   }
# }

data "terraform_remote_state" "chef" {
  backend = "consul"
  environment = "${terraform.env}"
  config {
    path = "aws/pcs/chef/tfstate"
  }
}


data "consul_keys" "config" {
  key {
    name    = "ami_id"
    path    = "aws/pcs/config/${var.org}/${var.environment}os/ami_id"
    default = "${var.ami_id}"
  }
  key {
    name = "os_type"
    path = "aws/pcs/config/${var.org}/${var.environment}/os/type"
  }
  key {
    name = "conn_user_name"
    path = "aws/pcs/config/${var.org}/${var.environment}/os/conn/user_name"
    default = "ec2-user"
  }
  key {
    name = "conn_key_name"
    path = "aws/pcs/config/${var.org}/${var.environment}/os/conn/key_name"
  }
  key {
    name = "conn_private_key"
    path = "aws/pcs/config/${var.org}/${var.environment}/os/conn/key_file"
  }
  key {
    name = "default_tags"
    path = "aws/pcs/config/${var.org}/${var.environment}/default_tags"
  }
  key {
    name = "region"
    path = "aws/pcs/config/${var.org}/${var.environment}/region"
  }
  key {
    name = "org"
    path = "aws/pcs/config/${var.org}/"
  }
  key {
    name = "environment"
    path = "aws/pcs/config/${var.org}/${var.environment}"
  }
  key {
    name    = "no_proxy"
    path    = "aws/pcs/config/${var.org}/${var.environment}/no_proxy"
    default = "169.254.169.254,localhost"
  }
  key {
    name    = "hostname"
    path    = "aws/pcs/config/${var.org}/${var.environment}/gitlab/hostname"
    default = "${length(var.hostname) > 0 ? var.hostname : "gitlab" }"   
  }
  key {
    name    = "instance_type"
    path    = "aws/pcs/config/${var.org}/${var.environment}/gitlab/instance_type"
    default = "m4.large"
  }
  key {
    name    = "install_url"
    path    = "aws/pcs/config/${var.org}/${var.environment}/chef/install_url"
    default = "https://packages.chef.io/files/stable/chef-server/12.16.2/el/7/chef-server-core-12.16.2-1.el7.x86_64.rpm"
  }  
  key {
    name    = "openvpn_enabled"
    path    = "aws/pcs/config/${var.org}/${var.environment}/openvpn/enabled"
    default = "false"   
  }
  key {
    name    = "openvpn_sg"
    path    = "aws/pcs/config/${var.org}/${var.environment}/openvpn/openvpn_sg"
  }
  key {
    name    = "route53_zone_id"
    path    = "aws/pcs/config/${var.org}/${var.environment}/route53_zone_id"
  }
  key {
    name    = "private_domain"
    path    = "aws/pcs/config/${var.org}/${var.environment}/private_domain"
    default = "${var.private_domain}"
  }
}
