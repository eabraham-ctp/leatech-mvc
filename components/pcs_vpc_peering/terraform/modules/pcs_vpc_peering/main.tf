# Cloud Technology Partners, Inc. https://www.cloudtp.com
#


# Configure the AWS region
provider "aws" {
  region = "${var.region}"
}

provider "aws" {
  alias   = "peer"
  profile = "${var.peer_acct_profile}"
  region  = "${var.region}"
}

data "aws_caller_identity" "accepter" {
  provider = "aws.peer"
}

data "aws_vpc" "peer_vpc" {
  provider = "aws.peer"
  tags {
    Name = "${var.peer_acct_profile}-VPC"
  }
}