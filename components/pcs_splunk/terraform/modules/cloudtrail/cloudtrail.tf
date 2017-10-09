
variable "org" {}
variable "environment" {}
variable "app" {}
variable "group" {}
variable "default_tags" {type="map"}

data "aws_region" "current" {current=true}
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "bucket" {
  bucket = "${lower(var.org)}-${lower(var.environment)}-cloudtrail-${data.aws_caller_identity.current.account_id}"
  acl    = "private"
  force_destroy = true
  
  versioning = {
    enabled = true
  }
  
  tags = "${merge(var.default_tags, map("Name", "${lower(var.org)}-${lower(var.environment)}-cloudtrail-${data.aws_caller_identity.current.account_id}"))}"
}

resource "aws_s3_bucket_policy" "bucket" {
  bucket = "${aws_s3_bucket.bucket.id}"
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
            "Resource": "arn:aws:s3:::${aws_s3_bucket.bucket.id}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.bucket.id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}

#Cloudtrail role
resource "aws_iam_role" "ct" {
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

# Cloud trail role policy
resource "aws_iam_policy" "ct" {
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
        "arn:aws:logs:*:*:log-group:/aws/cloudtrail/${var.org}/${var.environment}/${var.app}:log-stream:*"
      ]
    },
    {
      "Sid": "AWSCloudTrailPutLogEvents",
      "Effect": "Allow",
      "Action": [
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:*:*:log-group:/aws/cloudtrail/${var.org}/${var.environment}/${var.app}:log-stream:*"
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

# SNS Topic to get cloudtrail notifications
resource "aws_sns_topic" "ct" {
  name = "${upper(var.org)}-${upper(var.environment)}-Cloudtrail-Topic"
}

# Enable S3 to publish
resource "aws_sns_topic_policy" "ct" {
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

# S3 events Queue
resource "aws_sqs_queue" "ct" {
  name = "${upper(var.org)}-${upper(var.environment)}-Cloudtrail-SQS-Queue"
  delay_seconds              = 0
  max_message_size           = 262144
  visibility_timeout_seconds = 30
  message_retention_seconds  = 345600
  
  #enable long polling
  receive_wait_time_seconds  = 20
}

# Allow SNS to send messages to SQS Queue
resource "aws_sqs_queue_policy" "ct" {
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

# Link SNS and SQS
resource "aws_sns_topic_subscription" "sqs" {
  topic_arn = "${aws_sns_topic.ct.arn}"
  protocol  = "sqs"
  endpoint  = "${aws_sqs_queue.ct.arn}"
  depends_on = ["aws_sns_topic.ct", "aws_sqs_queue.ct"]
}

# S3 SNS Notifications
resource "aws_s3_bucket_notification" "ct" {
  bucket = "${aws_s3_bucket.bucket.id}"
  topic {
    topic_arn     = "${aws_sns_topic.ct.arn}"
    events        = ["s3:ObjectCreated:*"]
  }
}

#CloudTrail -> S3 > SNS > SQS
resource "aws_cloudtrail" "ct" {
  name                          = "${upper(var.org)}-${upper(var.environment)}-Cloudtrail"
  enable_logging                = true
  enable_log_file_validation    = false
  include_global_service_events = true
  is_multi_region_trail         = false
  
  #s3 logging
  s3_bucket_name                = "${aws_s3_bucket.bucket.id}"
  s3_key_prefix                 = "cloudtrail"
  
  #sns
  sns_topic_name                = "${aws_sns_topic.ct.id}"
  
  tags = "${merge(var.default_tags, map("Name", "${upper(var.org)}-${upper(var.environment)}-Cloudtrail"))}"
  
  depends_on = [
    "aws_s3_bucket_policy.bucket",
    "aws_sqs_queue.ct",
    "aws_sns_topic.ct",
    "aws_sqs_queue_policy.ct",
    "aws_sns_topic_subscription.sqs",
    "aws_sns_topic_policy.ct"
  ]
}



