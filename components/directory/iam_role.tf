# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Active Directory - bootstrap

# Create IAM Role for Windows EC2 instance
resource "aws_iam_instance_profile" "win-role-ssm-profile" {
  name = "${var.org}-winRoleSSMProfile-Service-Int-${var.environment}"
  role = "${aws_iam_role.win-role-ssm.name}"
}

resource "aws_iam_role" "win-role-ssm" {
  name = "${var.org}-winRoleSSM-Service-Int-${var.environment}"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "win-role-ssm-policy" {
  role = "${aws_iam_role.win-role-ssm.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}
