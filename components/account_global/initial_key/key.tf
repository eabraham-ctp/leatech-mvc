# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Consul Dataload - bootstrap
#
# Loads the configuraiton paramters in to Consul
#

provider "aws" {
  region = "${var.region}"
}

resource "aws_key_pair" "automation_key" {
  key_name = "${var.conn_key_name}"
  public_key = "${file(var.conn_public_key)}" #TECHDEBT
}

