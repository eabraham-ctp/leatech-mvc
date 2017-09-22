# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Gitlab

# Instance role to allow access
resource "aws_iam_role" "gitlab_instance_role" {
  name               = "${format("%s-%s-Gitlab-Service", var.org, var.environment)}"
  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF
}

# IAM policy allowing STS access
resource "aws_iam_policy" "ec2_policy" {
  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement":[{
      "Effect": "Allow",
      "Action": "ec2:*",
      "Resource": ["*"]
      }
    ]
  }
  EOF
}

resource "aws_iam_policy_attachment" "sts_policy_attachment" {
  name       = "${aws_iam_policy.ec2_policy.name}"
  roles      = [
    "${aws_iam_role.gitlab_instance_role.name}"]
  policy_arn = "${aws_iam_policy.ec2_policy.arn}"
}

# Instance role to be used by Gitlab server
resource "aws_iam_instance_profile" "gitlab_instance_profile" {
  name = "${format("%s-Gitlab-Service-Int-%s", var.org, var.environment)}"
  role = "${aws_iam_role.gitlab_instance_role.name}"
}
