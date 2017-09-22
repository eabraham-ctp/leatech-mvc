{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "KMSReadOnlyAllowGrant",
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt",
                "kms:DescribeKey",
                "kms:Encrypt",
                "kms:GenerateDataKey*",
                "kms:ReEncrypt*"
            ],
            "Resource": [
                "${kms_ami_key}",
                "${kms_general_key}"
            ]
        },
        {
            "Sid": "KMSEncryptedAllowGrant",
            "Effect": "Allow",
            "Action": [
                "kms:CreateGrant",
                "kms:List*",
                "kms:RevokeGrant"
            ],
            "Condition": {
                "Bool": {
                    "kms:GrantIsForAWSResource": "true"
                }
            },
            "Resource": [
                "${kms_ami_key}",
                "${kms_general_key}"
            ]
        },
        {
            "Sid": "KMSListDescribeKeysGrant",
            "Effect": "Allow",
            "Action": [
                "kms:DescribeKey",
                "kms:List*"
            ],
            "Resource": "*"
        }
    ]
}