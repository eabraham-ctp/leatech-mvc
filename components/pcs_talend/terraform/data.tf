data "terraform_remote_state" "vpc" {
  backend     = "consul"
  environment = "${terraform.env}"
  config {
    path = "aws/pcs/vpc/tfstate"
  }
}

data "terraform_remote_state" "consul" {
  backend = "consul"
  environment = "${terraform.env}"
  config {
    path = "aws/pcs/consul/tfstate"
  }
}

data "terraform_remote_state" "squid" {
  backend     = "consul"
  environment = "${terraform.env}"
  config {
    path = "aws/pcs/squid/tfstate"
  }
}

data "terraform_remote_state" "kms" {
  backend     = "consul"
  environment = "${terraform.env}"
  config {
    path = "aws/pcs/kms/tfstate"
  }
}   

data "terraform_remote_state" "rdsapp" {
  backend     = "consul"
  environment = "${terraform.env}"
  config {
    path = "aws/pcs/rdsapp/tfstate"
  }
}   
