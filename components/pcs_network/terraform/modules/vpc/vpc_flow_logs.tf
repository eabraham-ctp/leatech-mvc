# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Common Terraform Modules
# VPC - flow logs

resource "aws_cloudwatch_log_group" "vpc_flow_group" {
  name           = "${var.org}-${var.environment}"
}

resource "aws_flow_log" "vpc_flow_log" {
  # log_group_name needs to exist before hand
  # until we have a CloudWatch Log Group Resource
  log_group_name = "${aws_cloudwatch_log_group.vpc_flow_group.name}"
  iam_role_arn   = "${aws_iam_role.vpc_flow_role.arn}"
  vpc_id         = "${aws_vpc.vpc.id}"
  traffic_type   = "ALL"
}

resource "aws_iam_role" "vpc_flow_role" {
  name               = "${var.org}-VPCFlowLog-${var.environment}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "vpc_flow_policy" {
  name   = "${var.org}-VPCFlowLog-Service-Int-${var.environment}"
  role   = "${aws_iam_role.vpc_flow_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
