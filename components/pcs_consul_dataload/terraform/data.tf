# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Consul Dataload - bootstrap
#
# Loads the configuration paramters in to Consul
#

data "aws_ami" "base" {
  most_recent = true
  filter {
    name   = "image-id"
    values = ["${var.ami_id}"]
  }
  filter {
    name   = "tag:stage"
    values = ["Complete"]
  }
}

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
