# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Consul Dataload - bootstrap
#
# Loads the configuraiton paramters in to Consul
#

provider "consul" {
  #
  # No configuration required it pulls from the Consul agent on the loacal computer
  #
}

provider "aws" {
  region = "${var.region}"
}
