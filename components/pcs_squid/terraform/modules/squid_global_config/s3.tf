##### Not region specific purpose buckets #####


resource "aws_s3_bucket_object" "squid_conf" {
  bucket = "${var.backend_bucket_name}"
  key    = "${var.squid_conf_prefix}/squid.conf"
  source = "${pathexpand("${path.module}/squid.conf")}"
  # etag   = "${md5(file("${path.module}/squid.conf"))}"
  server_side_encryption = "aws:kms"
}

resource "aws_s3_bucket_object" "squid_allowed_sites" {
  bucket = "${var.backend_bucket_name}"
  key    = "${var.squid_conf_prefix}/allowed_sites"
  source = "${pathexpand("${path.module}/allowed_sites")}"
  # etag   = "${md5(file("${path.module}/allowed_sites"))}"
  server_side_encryption = "aws:kms"
}

resource "aws_s3_bucket_object" "squid_log_rotate" {
  bucket = "${var.backend_bucket_name}"
  key    = "${var.squid_conf_prefix}/squid-logrotate.conf"
  source = "${pathexpand("${path.module}/squid-logrotate.conf")}"
  # etag   = "${md5(file("${path.module}/squid-logrotate.conf"))}"
  server_side_encryption = "aws:kms"
}
