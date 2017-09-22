# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Active Directory - bootstrap

provider "aws" {
  region = "${var.aws_region}"
}

### BEGIN backend state storage
### Comment these lines out for initial bootstrap. After Consul is available,
### un-comment these lines and perform 'terraform init' to copy the state to Consul.
# terraform {
#   backend "consul" {
#     path = "aws/pcs/directory/tfstate"
#   }
# }
### END backend state storage
