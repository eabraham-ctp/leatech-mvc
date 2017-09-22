{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1429136633762",
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${elb_logging_bucket}/*",
      "Principal": {
        "AWS": [
          "${elb_logging_account}"
        ]
      }
    }
  ]
}
