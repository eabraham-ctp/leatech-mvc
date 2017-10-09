# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Jenkins

provider "consul" {
  #
  # No configuration requied it pulls from the Consul agent on the loacal computer
  #
}

provider "aws" {
  region = "${var.region}"
}
