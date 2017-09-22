##### Not region specific purpose buckets #####
provider "aws" {
  region = "${var.region}"
}

resource "aws_s3_bucket" "s3_bucket" {
  region = "${var.region}"
  lifecycle {
    prevent_destroy = false
  }
  bucket    = "${var.backend_bucket_name}"
  acl       = "private"
  versioning {
    enabled = true
  }
  tags      = "${var.default_tags}"  
}

output "s3_bucket_name" {
  value = "${aws_s3_bucket.s3_bucket.id}"
}
