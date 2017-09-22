# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# VPC (simple)
#
# Creates the VPC, with subnets, route tables, and other associated resources,
# for Platform Common Services (PCS). This version uses simple inbound/outbound
# subnets and routing.

# WARNING: Do not specify access key and secret key here. Use either environment
# variables or the ~/.aws/credentials file.
provider "aws" {
  region = "${var.region}"
}