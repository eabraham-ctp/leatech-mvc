#Create Splunk Role
resource "aws_iam_role" "splunk" {
  name = "${upper(var.org)}-${upper(var.environment)}-${var.app}-Role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow"
        },
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "vpc-flow-logs.amazonaws.com"
            },
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "splunk" {
  name = "${upper(var.org)}-${upper(var.environment)}-${var.app}-${var.app}-Policy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "GrantAccessToSplunkLogging",
            "Effect": "Allow",

            "Action": [
                "s3:ListBucket",
                "s3:GetObject",
                "s3:GetBucketLocation",
                "s3:ListAllMyBuckets",
                "s3:GetBucketTagging",
                "s3:GetAccelerateConfiguration",
                "s3:GetBucketLogging",
                "s3:GetLifecycleConfiguration",
                "s3:GetBucketCORS",
                "s3:Get*",
                "s3:List*",
                "s3:Delete*",
                "config:DeliverConfigSnapshot",
                "config:DescribeConfigRules",
                "config:DescribeConfigRuleEvaluationStatus",
                "config:GetComplianceDetailsByConfigRule",
                "config:GetComplianceSummaryByConfigRule",
                "cloudwatch:Describe*",
                "cloudwatch:Get*",
                "cloudwatch:List*",
                "cloudtrail:DescribeTrails",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:GetLogEvents",
                
                "sqs:ReceiveMessage",
                "sqs:SendMessage",
                "sqs:SendMessageBatch",
                "sqs:GetQueueAttributes",
                "sqs:ListQueues",
                "sqs:ListDeadLetterSourceQueues",
                "sqs:GetQueueUrl",
                "sqs:DeleteMessage",
                "sqs:DeleteMessageBatch",

                "sns:ListSubscriptionsByTopic",
                "sns:ListTopics",
                "sns:ListSubscriptions",
                "sns:Publish",
                "sns:GetSubscriptionAttributes",
                "sns:GetTopicAttributes",

                "ec2:DescribeInstances",
                "ec2:DescribeReservedInstances",
                "ec2:DescribeSnapshots",
                "ec2:DescribeRegions",
                "ec2:DescribeKeyPairs",
                "ec2:DescribeNetworkAcls",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeVolumes",
                "ec2:DescribeVpcs",
                "ec2:DescribeImages",
                "ec2:DescribeAddresses",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeInstanceHealth",
                "elasticloadbalancing:DescribeTags",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetHealth",
                "kinesis:Get*",
                "kinesis:DescribeStream",
                "kinesis:ListStreams",
                "iam:GetUser",
                "autoscaling:*",
                "lambda:ListFunctions",
                "rds:DescribeDBInstances",
                "cloudfront:ListDistributions",
                "inspector:Describe*",
                "inspector:List*",
                "kms:Decrypt"
            ],
            "Resource": ["*"]
        }
    ]
}
EOF
}

#Attache policy to Splunk role
resource "aws_iam_policy_attachment" "splunk" {
  name = "${upper(var.org)}-${upper(var.environment)}-${var.app}-Policy-Attachment"
  roles = ["${aws_iam_role.splunk.name}"]
  policy_arn = "${aws_iam_policy.splunk.arn}"
}

#Create role profile
resource "aws_iam_instance_profile" "splunk" {
  name = "${upper(var.org)}-${upper(var.environment)}-${var.app}-Profile"
  role = "${aws_iam_role.splunk.name}"
}