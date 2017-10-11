variable "org" {}
variable "environment" {}
variable "app" {}
variable "group" {}
variable "default_tags" {type="map"}
variable "cl_role_arn" {}
variable "cl_log_group_arn" {}
variable "bucket" {}
variable "bucket_prefix" {}
variable "sns_topic_name" {}
variable "kms_key" {}

resource "aws_cloudtrail" "ct" {
  name                          = "${upper(var.org)}-${upper(var.environment)}-Cloudtrail"
  enable_logging                = true
  enable_log_file_validation    = true
  include_global_service_events = true
  is_multi_region_trail         = false
  
  #cloudwatch
  cloud_watch_logs_role_arn     = "${var.cl_role_arn}"
  cloud_watch_logs_group_arn    = "${var.cl_log_group_arn}"
  
  #s3 logging
  s3_bucket_name                = "${var.bucket}"
  s3_key_prefix                 = "${var.bucket_prefix}"
  
  #sns
  sns_topic_name                = "${var.sns_topic_name}"
  
  #encryption
  kms_key_id                    = "${var.kms_key}"
  
  tags = "${merge(var.default_tags, map("Name", "${upper(var.org)}-${upper(var.environment)}-Cloudtrail"))}"
}
