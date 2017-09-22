{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:Get*",
        "s3:List*"
        ],
      "Resource": [
        "arn:aws:s3:::${backend_bucket_name}/${squid_conf_prefix}",
        "arn:aws:s3:::${backend_bucket_name}/${squid_conf_prefix}/*"
      ]
    }
  ]
}
