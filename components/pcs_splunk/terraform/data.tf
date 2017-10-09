# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Vault - bootstrap

data "terraform_remote_state" "vpc" {
  backend     = "consul"
  environment = "${terraform.env}"
  config {
    path = "aws/pcs/vpc/tfstate"
  }
}

data "consul_keys" "config" {
  key {
    name = "conn_user_name"
    path = "aws/pcs/config/${var.org}/${var.environment}/os/conn/user_name"
  }

  key {
    name = "conn_key_name"
    path = "aws/pcs/config/${var.org}/${var.environment}/os/conn/key_name"
  }

  key {
    name = "conn_private_key"
    path = "aws/pcs/config/${var.org}/${var.environment}/os/conn/key_file"
  }
  
}
