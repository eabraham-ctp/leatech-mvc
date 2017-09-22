# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Vault
 
# Role name format
# <Org/BU>-<Role>-<User|Service>-<Type SAML|Int|Ext>-<Environment>

# Instance role to allow access
resource "aws_iam_role" "vault_instance_role" {
  name = "${var.org}-Vault-Service-Int-${var.environment}"
  
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
resource "aws_iam_policy" "sts_policy" {
  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement":[{
      "Effect": "Allow",
      "Action": "sts:*",
      "Resource": ["*"]
      }
    ]
  }
  EOF
}

resource "aws_iam_policy_attachment" "sts_policy_attachment" {
  name       = "${aws_iam_policy.sts_policy.name}"
  roles      = [
    "${aws_iam_role.vault_instance_role.name}"]
  policy_arn = "${aws_iam_policy.sts_policy.arn}"
}

# Instance role to be used by Vault server
resource "aws_iam_instance_profile" "vault_instance_profile" {
  name   = "${upper(var.org)}-InstanceRole-policy"  
  role = "${aws_iam_role.vault_instance_role.name}"
}
