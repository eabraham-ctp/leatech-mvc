variable "org" {}
variable "environment" {}
variable "app" {}
variable "group" {}
variable "default_tags" {type="map"}
variable "kms_key" {}
variable "ct_account_numbers" {type = "list"}
variable "ct_accounts" {type = "list"}
variable "ct_account_name" {}
variable "ct_trails" {type = "list"}
variable "force_destroy" {}
variable "versioning" {}

output "cl_role_arn" { value = "${aws_iam_role.ct.arn}" }
output "cl_log_group_arn" { value = "${aws_cloudwatch_log_group.ct.arn}" }
output "bucket" { value = "${aws_s3_bucket.kms.id}" }
output "sns_topic_name" { value = "${aws_sns_topic.ct.id}" }


data "aws_region" "current" {current=true}
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "kms" {
  #Cloudtrail Logs
  bucket = "${lower(var.org)}-${lower(var.environment)}-cloudtrail-kms-logs"
  acl    = "private"
  force_destroy = "${var.force_destroy}"
  
  versioning = {
    enabled = "${var.versioning}"
  }
  tags = "${merge(var.default_tags, map("Name", "${lower(var.org)}-${lower(var.environment)}-cloudtrail-kms-log"))}"
}

resource "aws_s3_bucket" "logs" {
  #Cloudtrail Logs
  bucket = "${lower(var.org)}-${lower(var.environment)}-cloudtrail-logs"
  acl    = "private"
  force_destroy = "${var.force_destroy}"
  
  versioning = {
    enabled = "${var.versioning}"
  }
  tags = "${merge(var.default_tags, map("Name", "${lower(var.org)}-${lower(var.environment)}-cloudtrail-logs"))}"
}

resource "aws_cloudwatch_log_group" "ct" {
  #CloudWatch Log
  name = "/${var.org}/${var.environment}/Cloudtrail-CW-LOG"
  tags = "${merge(var.default_tags, map("Name", "/${var.org}/${var.environment}/Cloudtrail-CW-LOG"))}"
}

resource "aws_s3_bucket_policy" "kms" {
  # S3 Bucket Policy
  bucket = "${aws_s3_bucket.kms.id}"
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.kms.id}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.kms.id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        },
        {
          "Sid":"CroosAccountPutObject",
          "Effect":"Allow",
          "Principal": {"AWS": "*"},
          "Action": "s3:PutObject",
          "Resource":["arn:aws:s3:::${aws_s3_bucket.kms.id}/*"]
        }
    ]
}
POLICY
}

resource "aws_s3_bucket_policy" "logs" {
  # S3 Bucket Policy
  bucket = "${aws_s3_bucket.logs.id}"
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.logs.id}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.logs.id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        },
        {
          "Sid":"CroosAccountPutObject",
          "Effect":"Allow",
          "Principal": {"AWS": "*" },
          "Action":["s3:PutObject"],
          "Resource":["arn:aws:s3:::${aws_s3_bucket.logs.id}/*"]
        }
    ]
}
POLICY
}

resource "aws_iam_role" "ct" {
  #Cloudtrail role
  name = "${upper(var.org)}-${upper(var.environment)}-${var.app}-Cloudtrail-Role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "ct" {
  # Cloud trail role policy
  name = "${upper(var.org)}-${upper(var.environment)}-Cloudtrail-CloudWatch-Policy"
  description = "Deliver logs from CloudTrail to CloudWatch."
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AWSCloudTrailCreateLogStream",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream"
      ],
      "Resource": [
        "arn:aws:logs:*:*:log-group:/${var.org}/${var.environment}/Cloudtrail-CW-LOG:log-stream:*"
      ]
    },
    {
      "Sid": "AWSCloudTrailPutLogEvents",
      "Effect": "Allow",
      "Action": [
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:*:*:log-group:/${var.org}/${var.environment}/Cloudtrail-CW-LOG:log-stream:*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ct" {
  role = "${aws_iam_role.ct.name}"
  policy_arn = "${aws_iam_policy.ct.arn}"
  depends_on = ["aws_iam_role.ct", "aws_iam_policy.ct"]
}

resource "aws_sns_topic" "ct" {
  # SNS Topic to get cloudtrail notifications
  name = "${upper(var.org)}-${upper(var.environment)}-Cloudtrail-Topic"
}

resource "aws_sns_topic_policy" "ct" {
  # Enable S3 to publish
  depends_on = ["aws_sns_topic.ct"]
  arn = "${aws_sns_topic.ct.arn}"
  policy = <<POLICY
{
    "Version":"2012-10-17",
    "Statement":[{
        "Effect": "Allow",
        "Principal": {"AWS":"*"},
        "Action": "SNS:Publish",
        "Resource": "${aws_sns_topic.ct.arn}"
    }]
}
POLICY
}

resource "aws_sqs_queue" "ct" {
  # S3 events Queue
  name = "${upper(var.org)}-${upper(var.environment)}-Cloudtrail-SQS-Queue"
  delay_seconds              = 0
  max_message_size           = 262144
  visibility_timeout_seconds = 30
  message_retention_seconds  = 345600
  
  #enable long polling
  receive_wait_time_seconds  = 20
}

resource "aws_sqs_queue_policy" "ct" {
  # Allow SNS to send messages to SQS Queue
  depends_on = ["aws_sqs_queue.ct"]
  queue_url = "${aws_sqs_queue.ct.id}"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.ct.arn}",
      "Condition": {"ArnEquals": { "aws:SourceArn": "${aws_sns_topic.ct.arn}"}}
    }
  ]
}
POLICY
}

resource "aws_sns_topic_subscription" "sqs" {
  # Link SNS and SQS
  topic_arn = "${aws_sns_topic.ct.arn}"
  protocol  = "sqs"
  endpoint  = "${aws_sqs_queue.ct.arn}"
  depends_on = ["aws_sns_topic.ct", "aws_sqs_queue.ct"]
}

resource "aws_s3_bucket_notification" "ct" {
  # S3 SNS Notifications
  bucket = "${aws_s3_bucket.kms.id}"
  topic {
    topic_arn     = "${aws_sns_topic.ct.arn}"
    events        = ["s3:ObjectCreated:*"]
  }
  depends_on = ["aws_sns_topic.ct", "aws_s3_bucket_policy.kms"]
}
