# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Trend Server Marketplace
#
# Module for creating the Trend Deep Scan Serverfor Platform Common Services (PCS). This version uses
# Terraform scripts and Marketplace AMI
#
# Creates the metering role for the trend micro server

resource "aws_iam_role" "tm_metering" {
  name = "${var.org}-${var.group}-${var.environment}-TrendMicroRole-service-role"

  assume_role_policy = <<EOF
{
  		"Version": "2012-10-17",
  		"Statement": [ {
     	 	"Action": "sts:AssumeRole",
      		"Principal": {
        		"Service": "ec2.amazonaws.com"
      		},
      		"Effect": "Allow",
      		"Sid": ""
    	} ]
	}
	EOF
}

resource "aws_iam_instance_profile" "tm_metering" {
  name = "${var.org}-${var.group}-${var.environment}-TrendMicroDSM-instance-profile"

  role = "${aws_iam_role.tm_metering.name}"
  depends_on = [ 
  	"aws_iam_role.tm_metering" 
  ]
}

resource "aws_iam_role_policy" "tm_metering" {
  name = "${var.org}-${var.group}-${var.environment}-TrendMicroDSM-policy"
  role = "${aws_iam_role.tm_metering.id}"
  policy = "${file("${path.module}/iam_policy.json")}"

  depends_on = [
    "aws_iam_instance_profile.tm_metering"]
}
