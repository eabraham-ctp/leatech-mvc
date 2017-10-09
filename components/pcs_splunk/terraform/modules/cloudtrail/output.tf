// Outputs
output "cloudtrail_id" {
  value = "${aws_cloudtrail.ct.id}"
}

output "cloudtrail_home_region" {
  value = "${aws_cloudtrail.ct.home_region}"
}

output "cloudtrail_arn" {
  value = "${aws_cloudtrail.ct.arn}"
}

output "iam_role_cloudtrail_arn" {
  value = "${aws_iam_role.ct.arn}"
}

output "s3_bucket_id" {
  value = "${aws_s3_bucket.bucket.bucket_id}"
}

output "s3_bucket_arn" {
  value = "${aws_s3_bucket.bucket.bucket_arn}"
}

output "aws_sns_topic_id" {
  value = "${aws_sns_topic.ct.arn}"
}

output "aws_sqs_queue_arn" {
  value = "${aws_sqs_queue.ct.arn}"
}

output "aws_sqs_queue_url" {
  value = "${aws_sqs_queue.ct.id}"
}