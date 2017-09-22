# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# One time resources for Bootstrap Process
#
#

# Configure the AWS region
provider "aws" {
  region = "${var.region}"
}

# Provide access to the AWS account number
data "aws_caller_identity" "current" {}
