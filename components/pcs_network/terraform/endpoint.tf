# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# VPC (simple)
#
# Creates the VPC, with subnets, route tables, and other associated resources,
# for Platform Common Services (PCS). This version uses simple inbound/outbound
# subnets and routing.

# S3 endpoint for the VPC

resource "aws_vpc_endpoint" "S3-Endpoint" {
  vpc_id       = "${module.vpc.vpc_id}"
  service_name = "com.amazonaws.${var.region}.s3"
}