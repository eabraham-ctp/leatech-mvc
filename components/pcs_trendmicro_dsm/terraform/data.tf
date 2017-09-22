# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Trend Micro - bootstrap

data "terraform_remote_state" "vpc" {
  backend     = "consul"
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

data "terraform_remote_state" "consul" {
  backend     = "consul"
  environment = "${terraform.env}"
  config {
    path = "aws/pcs/consul/tfstate"
  }
}

data "terraform_remote_state" "vault" {
  backend     = "consul"
  environment = "${terraform.env}"
  config {
    path = "aws/pcs/vault/tfstate"
  }
}

data "terraform_remote_state" "workstations" {
  backend     = "consul"
  environment = "${terraform.env}"
  config {
    path = "aws/pcs/workstations/tfstate"
  }
}

data "terraform_remote_state" "route53" {
  backend     = "consul"
  environment = "${terraform.env}"
  config {
    path = "aws/pcs/route53/tfstate"
  }
}

data "consul_keys" "config" {
  key {
    name = "ami_id"
    path = "aws/pcs/config/${upper(element(split("-",var.org),0))}-${upper(var.group)}/${upper(var.environment)}/os/ami_id"
  }

  key {
    name = "os_type"
    path = "aws/pcs/config/${upper(element(split("-",var.org),0))}-${upper(var.group)}/${upper(var.environment)}/os/type"
  }

  key {
    name = "conn_user_name"
    path = "aws/pcs/config/${upper(element(split("-",var.org),0))}-${upper(var.group)}/${upper(var.environment)}/os/conn/user_name"
  }

  key {
    name = "conn_key_name"
    path = "aws/pcs/config/${upper(element(split("-",var.org),0))}-${upper(var.group)}/${upper(var.environment)}/os/conn/key_name"
  }

  key {
    name = "general_kms"
    path = "aws/pcs/config/${upper(element(split("-",var.org),0))}-${upper(var.group)}/${upper(var.environment)}/general_kms"
  }
}

#TECHDEBT - there are some values that should be stored in Vault.  
#data "vault_generic_secret" "connection" {
#  path = "secret/${lower(data.consul_keys.config.var.org)}/${lower(data.consul_keys.config.var.group)}/${lower(data.consul_keys.config.var.environment)}/conn"
#}
