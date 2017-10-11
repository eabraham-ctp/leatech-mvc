
//resource "aws_kms_key" "kms" {
//  description = "necryption kms key"
//  deletion_window_in_days = 7
//  policy = <<EOF
//{
//    "Version": "2012-10-17",
//    "Statement": [
//       {
//        "Sid": "Enable IAM User Permissions",
//        "Effect": "Allow",
//        "Principal": {
//          "AWS": "*"
//        },
//        "Action": "kms:*",
//        "Resource": "*"
//      },
//      {
//        "Sid": "Allow CloudTrail to encrypt logs",
//        "Effect": "Allow",
//        "Principal": {
//          "Service": "cloudtrail.amazonaws.com"
//        },
//        "Action": "kms:GenerateDataKey*",
//        "Resource": "*",
//        "Condition": {
//          "StringLike": {
//            "kms:EncryptionContext:aws:cloudtrail:arn": "arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"
//          }
//        }
//      },
//      {
//        "Sid": "Allow CloudTrail to describe key",
//        "Effect": "Allow",
//        "Principal": {
//          "Service": "cloudtrail.amazonaws.com"
//        },
//        "Action": "kms:DescribeKey",
//        "Resource": "*"
//      },
//      {
//        "Sid": "Allow principals in the account to decrypt log files",
//        "Effect": "Allow",
//        "Principal": {
//          "AWS": "*"
//        },
//        "Action": [
//          "kms:Decrypt",
//          "kms:ReEncryptFrom"
//        ],
//        "Resource": "*",
//        "Condition": {
//          "StringEquals": {
//            "kms:CallerAccount": "${data.aws_caller_identity.current.account_id}"
//          },
//          "StringLike": {
//              "kms:EncryptionContext:aws:cloudtrail:arn": "arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"
//          }
//        }
//      },
//      {
//        "Sid": "Allow alias creation during setup",
//        "Effect": "Allow",
//        "Principal": {
//          "AWS": "*"
//        },
//        "Action": "kms:CreateAlias",
//        "Resource": "*",
//        "Condition": {
//          "StringEquals": {
//            "kms:CallerAccount": "${data.aws_caller_identity.current.account_id}",
//            "kms:ViaService": "ec2.${data.aws_region.current.name}.amazonaws.com"
//          }
//        }
//      },
//      {
//        "Sid": "Enable cross account log decryption",
//        "Effect": "Allow",
//        "Principal": {
//          "AWS": "*"
//        },
//        "Action": [
//          "kms:Decrypt",
//          "kms:ReEncryptFrom"
//        ],
//        "Resource": "*",
//        "Condition": {
//          "StringEquals": {
//             "kms:CallerAccount": "${data.aws_caller_identity.current.account_id}"
//          },
//          "StringLike": {
//            "kms:EncryptionContext:aws:cloudtrail:arn": "arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"
//          }
//        }
//      }
//    ]
//}
//EOF
//}
//
