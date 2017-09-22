# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# IAM Roles
#
# Creates the IAM user roles for federation with Active Directory.

provider "aws" {
  region = "${var.region}"
}

#terraform {
# backend "consul" {
#   path = "aws/pcs/roles/tfstate"
# }
#}

# Role name format
# <Org/BU>-<Role>-<User|Service>-<Type SAML|Int|Ext>-<Environment>
# Policy name format
# <Org/BU>-<Function>-<Environment>


# variable "justorg" {
#   default = "${element(split("-", var.org),0)}"
# }

#Custom Policies
resource "aws_iam_policy" "AuditAdmin" {
  name       = "${element(split("-", var.org),0)}-AuditAdmin-policy"
  policy     = "${file("${path.module}/AuditAdmin_iam_policy.json")}"
}

resource "aws_iam_policy" "BillingDeny" {
  name       = "${element(split("-", var.org),0)}-BillingDeny-policy"
  policy     = "${file("${path.module}/BillingDeny_iam_policy.json")}"
}

resource "aws_iam_policy" "CloudAdmin" {
  name       = "${element(split("-", var.org),0)}-CloudAdmin-policy"
  policy     = "${file("${path.module}/CloudAdmin_iam_policy.json")}"
}

resource "aws_iam_policy" "DevOpsAdmin" {
  name       = "${element(split("-", var.org),0)}-DevOpsAdmin-policy"
  policy     = "${file("${path.module}/DevOpsAdmin_iam_policy.json")}"
}

resource "aws_iam_policy" "Dome9ReadOnly" {
  name       = "${element(split("-", var.org),0)}-Dome9ReadOnly-policy"
  policy     = "${file("${path.module}/Dome9ReadOnly_iam_policy.json")}"
}

resource "aws_iam_policy" "GeneralDeny" {
  name       = "${element(split("-", var.org),0)}-GeneralDeny-policy"
  policy     = "${file("${path.module}/GeneralDeny_iam_policy.json")}"
}

resource "aws_iam_policy" "IAMEngineering" {
  name       = "${element(split("-", var.org),0)}-IAMEngineering-policy"
  policy     = "${file("${path.module}/IAMEngineering_iam_policy.json")}"
}

resource "aws_iam_policy" "MessagingFullAccess" {
  name       = "${element(split("-", var.org),0)}-MessagingFullAccess-policy"
  policy     = "${file("${path.module}/MessagingFullAccess_iam_policy.json")}"
}

resource "aws_iam_policy" "RegionalDeny" {
  name       = "${element(split("-", var.org),0)}-RegionalDeny-policy"
  policy     = "${file("${path.module}/RegionalDeny_iam_policy.json")}"
}


resource "aws_iam_policy" "StorageFull" {
  name       = "${element(split("-", var.org),0)}-StorageFull-policy"
  policy     = "${file("${path.module}/StorageFull_iam_policy.json")}"
}


resource "aws_iam_policy" "TrendMicro" {
  name       = "${element(split("-", var.org),0)}-TrendMicro-policy"
  policy     = "${file("${path.module}/TrendMicro_iam_policy.json")}"
}

data "template_file" "kms_readonly_policy_template" {
  template              = "${file("${path.module}/kms_readonly_policy.tpl")}"
  vars {
    kms_ami_key       = "${data.terraform_remote_state.kms.pcs_ami_kms}",
    kms_general_key   = "${data.terraform_remote_state.kms.pcs_general_kms}"
  }
}

resource "aws_iam_policy" "KMSReadOnly" {
  name                  = "${element(split("-", var.org),0)}-KMSReadOnly-policy" 
  policy                = "${data.template_file.kms_readonly_policy_template.rendered}"
}

#MasterAdmin Role
resource "aws_iam_role" "MasterAdmin" {
  name               = "${element(split("-", var.org),0)}-MasterAdmin-user-role"

  assume_role_policy = <<EOF
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

resource "aws_iam_role_policy_attachment" "MasterAdmin_AdministratorAccess_policy_attachment" {
    role       = "${aws_iam_role.MasterAdmin.name}" 
    policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}


#IAMAdmin Role
resource "aws_iam_role" "IAMAdmin" {
  name               = "${element(split("-", var.org),0)}-IAMAdmin-user-role"

  assume_role_policy = <<EOF
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

resource "aws_iam_policy" "IAMAdmin" {
  name       = "${element(split("-", var.org),0)}-IAMAdmin-policy"
  policy     = "${file("${path.module}/IAMAdmin_iam_policy.json")}"
}

resource "aws_iam_role_policy_attachment" "IAMAdmin_GeneralDeny_policy_attachment" {
    role       = "${aws_iam_role.IAMAdmin.name}"
    policy_arn = "${aws_iam_policy.GeneralDeny.arn}"
}

resource "aws_iam_role_policy_attachment" "IAMAdmin_IamFullAccess_policy_attachment" {
    role       = "${aws_iam_role.IAMAdmin.name}" 
    policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

resource "aws_iam_role_policy_attachment" "IAMAdmin_RegionalDeny_policy_attachment" {
    role       = "${aws_iam_role.IAMAdmin.name}"
    policy_arn = "${aws_iam_policy.RegionalDeny.arn}"
}

# resource "aws_iam_role_policy_attachment" "IAMAdmin_policy_attachment" {
#     role       = "${aws_iam_role.IAMAdmin.name}"
#     policy_arn = "${aws_iam_policy.IAMAdmin.arn}"
# }


#KMSAdmin Role
resource "aws_iam_role" "KMSAdmin" {
  name               = "${element(split("-", var.org),0)}-KMSAdmin-user-role"

  assume_role_policy = <<EOF
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

resource "aws_iam_policy" "KMSAdmin" {
  name       = "${element(split("-", var.org),0)}-KMSAdmin-policy"
  policy     = "${file("${path.module}/KMSAdmin_iam_policy.json")}"
}

resource "aws_iam_role_policy_attachment" "KMSAdmin_GeneralDeny_policy_attachment" {
    role       = "${aws_iam_role.KMSAdmin.name}"
    policy_arn = "${aws_iam_policy.GeneralDeny.arn}"
}

resource "aws_iam_role_policy_attachment" "KMSAdmin_RegionalDeny_policy_attachment" {
    role       = "${aws_iam_role.KMSAdmin.name}"
    policy_arn = "${aws_iam_policy.RegionalDeny.arn}"
}

resource "aws_iam_role_policy_attachment" "KMSAdmin_AWSCertificateManagerFullAccess_policy_attachment" {
    role       = "${aws_iam_role.KMSAdmin.name}" 
    policy_arn = "arn:aws:iam::aws:policy/AWSCertificateManagerFullAccess"
}

resource "aws_iam_role_policy_attachment" "KMSAdmin_AWSKeyManagementServicePowerUser_policy_attachment" {
    role       = "${aws_iam_role.KMSAdmin.name}" 
    policy_arn = "arn:aws:iam::aws:policy/AWSKeyManagementServicePowerUser"
}


#CloudAdmin Role
resource "aws_iam_role" "CloudAdmin" {
  name               = "${element(split("-", var.org),0)}-CloudAdmin-user-role"

  assume_role_policy = <<EOF
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

resource "aws_iam_role_policy_attachment" "CloudAdmin_AdministratorAccess_policy_attachment" {
    role       = "${aws_iam_role.CloudAdmin.name}" 
    policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role_policy_attachment" "CloudAdmin_GeneralDeny_policy_attachment" {
    role       = "${aws_iam_role.CloudAdmin.name}"
    policy_arn = "${aws_iam_policy.GeneralDeny.arn}"
}

resource "aws_iam_role_policy_attachment" "CloudAdmin_IamEngineering_policy_attachment" {
    role       = "${aws_iam_role.CloudAdmin.name}" 
    policy_arn = "${aws_iam_policy.IAMEngineering.arn}"
}

resource "aws_iam_role_policy_attachment" "CloudAdmin_KMSReadOnly_policy_attachment" {
    role       = "${aws_iam_role.CloudAdmin.name}" 
    policy_arn = "${aws_iam_policy.KMSReadOnly.arn}"
}

resource "aws_iam_role_policy_attachment" "CloudAdmin_RegionalDeny_policy_attachment" {
    role       = "${aws_iam_role.CloudAdmin.name}"
    policy_arn = "${aws_iam_policy.RegionalDeny.arn}"
}


#DevopsAdmin
resource "aws_iam_role" "DevOps" {
  name               = "${element(split("-", var.org),0)}-DevOps-user-role"

  assume_role_policy = <<EOF
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

resource "aws_iam_role_policy_attachment" "DevOps_DevOpsAdmin_policy_attachment" {
    role       = "${aws_iam_role.DevOps.name}"
    policy_arn = "${aws_iam_policy.DevOpsAdmin.arn}"
}

resource "aws_iam_role_policy_attachment" "DevOps_MessagingFullAccess_policy_attachment" {
    role       = "${aws_iam_role.DevOps.name}"
    policy_arn = "${aws_iam_policy.MessagingFullAccess.arn}"
}

resource "aws_iam_role_policy_attachment" "DevOps_GeneralDeny_policy_attachment" {
    role       = "${aws_iam_role.DevOps.name}"
    policy_arn = "${aws_iam_policy.GeneralDeny.arn}"
}

resource "aws_iam_role_policy_attachment" "DevOps_RegionalDeny_policy_attachment" {
    role       = "${aws_iam_role.DevOps.name}"
    policy_arn = "${aws_iam_policy.RegionalDeny.arn}"
}

resource "aws_iam_role_policy_attachment" "DevOpsAdmin_AmazonEC2FullAccess_policy_attachment" {
    role       = "${aws_iam_role.DevOps.name}" 
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "DevOps_AmazonElasticMapReduceFullAccess_policy_attachment" {
    role       = "${aws_iam_role.DevOps.name}" 
    policy_arn = "arn:aws:iam::aws:policy/AmazonElasticMapReduceFullAccess"
}
resource "aws_iam_role_policy_attachment" "DevOps_AmazonRedshiftFullAccess_policy_attachment" {
    role       = "${aws_iam_role.DevOps.name}" 
    policy_arn = "arn:aws:iam::aws:policy/AmazonRedshiftFullAccess"
}
resource "aws_iam_role_policy_attachment" "DevOps_AWSQuicksightAthenaAccess_policy_attachment" {
    role       = "${aws_iam_role.DevOps.name}" 
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSQuicksightAthenaAccess"
}

resource "aws_iam_role_policy_attachment" "DevOps_AWSLambdaFullAccess_policy_attachment" {
    role       = "${aws_iam_role.DevOps.name}" 
    policy_arn = "arn:aws:iam::aws:policy/AWSLambdaFullAccess"
}

resource "aws_iam_role_policy_attachment" "DevOps_KMSReadOnly_policy_attachment" {
    role       = "${aws_iam_role.DevOps.name}" 
    policy_arn = "${aws_iam_policy.KMSReadOnly.arn}"
}

#DeveloperRole
resource "aws_iam_role" "Developer" {
  name               = "${element(split("-", var.org),0)}-Developer-user-role"

  assume_role_policy = <<EOF
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

resource "aws_iam_role_policy_attachment" "Developer_StorageFull_policy_attachment" {
    role       = "${aws_iam_role.Developer.name}"
    policy_arn = "${aws_iam_policy.StorageFull.arn}"
}

resource "aws_iam_role_policy_attachment" "Developer_GeneralDeny_policy_attachment" {
    role       = "${aws_iam_role.Developer.name}"
    policy_arn = "${aws_iam_policy.GeneralDeny.arn}"
}

resource "aws_iam_role_policy_attachment" "Developer_AmazonEC2FullAccess_policy_attachment" {
    role       = "${aws_iam_role.Developer.name}" 
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "Developer_AmazonElasticMapReduceFullAccess_policy_attachment" {
    role       = "${aws_iam_role.Developer.name}" 
    policy_arn = "arn:aws:iam::aws:policy/AmazonElasticMapReduceFullAccess"
}
resource "aws_iam_role_policy_attachment" "Developer_AmazonRedshiftFullAccess_policy_attachment" {
    role       = "${aws_iam_role.Developer.name}" 
    policy_arn = "arn:aws:iam::aws:policy/AmazonRedshiftFullAccess"
}
resource "aws_iam_role_policy_attachment" "Developer_AWSQuicksightAthenaAccess_policy_attachment" {
    role       = "${aws_iam_role.Developer.name}" 
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSQuicksightAthenaAccess"
}

resource "aws_iam_role_policy_attachment" "Developer_KMSReadOnly_policy_attachment" {
    role       = "${aws_iam_role.Developer.name}" 
    policy_arn = "${aws_iam_policy.KMSReadOnly.arn}"
}

resource "aws_iam_role_policy_attachment" "Developer_RegionalDeny_policy_attachment" {
    role       = "${aws_iam_role.Developer.name}"
    policy_arn = "${aws_iam_policy.RegionalDeny.arn}"
}




#SecurityAdminRole 
resource "aws_iam_role" "SecurityAdmin" {
  name               = "${element(split("-", var.org),0)}-SecurityAdmin-user-role"

  assume_role_policy = <<EOF
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

resource "aws_iam_role_policy_attachment" "SecurityAdmin_BillingDeny_policy_attachment" {
    role       = "${aws_iam_role.SecurityAdmin.name}"
    policy_arn = "${aws_iam_policy.BillingDeny.arn}"
}

resource "aws_iam_role_policy_attachment" "SecurityAdmin_AWSWAFFullAccess_policy_attachment" {
    role       = "${aws_iam_role.SecurityAdmin.name}" 
    policy_arn = "arn:aws:iam::aws:policy/AWSWAFFullAccess"
}

resource "aws_iam_role_policy_attachment" "SecurityAdmin_AmazonS3FullAccess_policy_attachment" {
    role       = "${aws_iam_role.SecurityAdmin.name}" 
    policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "SecurityAdmin_AWSCloudTrailFullAccess_policy_attachment" {
    role       = "${aws_iam_role.SecurityAdmin.name}" 
    policy_arn = "arn:aws:iam::aws:policy/AWSCloudTrailFullAccess"
}

resource "aws_iam_role_policy_attachment" "SecurityAdmin_AmazonVPCFullAccess_policy_attachment" {
    role       = "${aws_iam_role.SecurityAdmin.name}" 
    policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}

resource "aws_iam_role_policy_attachment" "SecurityAdmin_AmazonInspectorFullAccess_policy_attachment" {
    role       = "${aws_iam_role.SecurityAdmin.name}" 
    policy_arn = "arn:aws:iam::aws:policy/AmazonInspectorFullAccess"
}

resource "aws_iam_role_policy_attachment" "SecurityAdmin_AmazonCloudDirectoryFullAccess_policy_attachment" {
    role       = "${aws_iam_role.SecurityAdmin.name}" 
    policy_arn = "arn:aws:iam::aws:policy/AmazonCloudDirectoryFullAccess"
}

resource "aws_iam_role_policy_attachment" "SecurityAdmin_AWSDirectoryServiceFullAccess_policy_attachment" {
    role       = "${aws_iam_role.SecurityAdmin.name}" 
    policy_arn = "arn:aws:iam::aws:policy/AWSDirectoryServiceFullAccess"
}
resource "aws_iam_role_policy_attachment" "SecurityAdmin_AmazonRDSDirectoryServiceAccess_policy_attachment" {
    role       = "${aws_iam_role.SecurityAdmin.name}" 
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSDirectoryServiceAccess"
}





#AuditAdminRole 
resource "aws_iam_role" "AuditAdmin" {
  name               = "${element(split("-", var.org),0)}-AuditAdmin-user-role"

  assume_role_policy = <<EOF
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

resource "aws_iam_role_policy_attachment" "AuditAdmin_SecurityAudit_policy_attachment" {
    role       = "${aws_iam_role.AuditAdmin.name}" 
    policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}


resource "aws_iam_policy_attachment" "AuditAdmin_policy_attachment" {
  name       = "${aws_iam_policy.AuditAdmin.name}"
  roles      = [
    "${aws_iam_role.AuditAdmin.name}"]
  policy_arn = "${aws_iam_policy.AuditAdmin.arn}"
}

resource "aws_iam_role_policy_attachment" "AuditAdmin_RegionalDeny_policy_attachment" {
    role       = "${aws_iam_role.AuditAdmin.name}"
    policy_arn = "${aws_iam_policy.RegionalDeny.arn}"
}


#BillingAdmin Role
resource "aws_iam_role" "BillingAdmin" {
  name               = "${element(split("-", var.org),0)}-BillingAdmin-user-role"

  assume_role_policy = <<EOF
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

resource "aws_iam_policy" "BillingAdmin" {
  name       = "${element(split("-", var.org),0)}-BillingAdmin-policy"
  policy     = "${file("${path.module}/BillingAdmin_iam_policy.json")}"
}

resource "aws_iam_policy_attachment" "BillingAdmin_policy_attachment" {
  name       = "${aws_iam_policy.BillingAdmin.name}"
  roles      = [
    "${aws_iam_role.BillingAdmin.name}"]
  policy_arn = "${aws_iam_policy.BillingAdmin.arn}"
}

## CloudOps role 
resource "aws_iam_role" "CloudOps" {
  name               = "${element(split("-", var.org),0)}-CloudOps-user-role"

  assume_role_policy = <<EOF
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

resource "aws_iam_role_policy_attachment" "CloudOps_ViewOnlyAccess_policy_attachment" {
    role       = "${aws_iam_role.CloudOps.name}" 
    policy_arn = "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "CloudOps_AWSSupportAccess_policy_attachment" {
    role       = "${aws_iam_role.CloudOps.name}" 
    policy_arn = "arn:aws:iam::aws:policy/AWSSupportAccess"
}

resource "aws_iam_role_policy_attachment" "CloudOps_AWSCloudTrailFullAccess_policy_attachment" {
    role       = "${aws_iam_role.CloudOps.name}" 
    policy_arn = "arn:aws:iam::aws:policy/AWSCloudTrailFullAccess"
}

resource "aws_iam_role_policy_attachment" "CloudOps_CloudWatchFullAccess_policy_attachment" {
    role       = "${aws_iam_role.CloudOps.name}" 
    policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_role_policy_attachment" "CloudOps_RegionalDeny_policy_attachment" {
    role       = "${aws_iam_role.CloudOps.name}"
    policy_arn = "${aws_iam_policy.RegionalDeny.arn}"
}

resource "aws_iam_role_policy_attachment" "CloudOps_KMSReadOnly_policy_attachment" {
    role       = "${aws_iam_role.CloudOps.name}" 
    policy_arn = "${aws_iam_policy.KMSReadOnly.arn}"
}

## ReadOnly role 
resource "aws_iam_role" "ReadOnly" {
  name               = "${element(split("-", var.org),0)}-ReadOnly-user-role"

  assume_role_policy = <<EOF
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

resource "aws_iam_role_policy_attachment" "ReadOnly_ViewOnlyAccess_policy_attachment" {
    role       = "${aws_iam_role.ReadOnly.name}" 
    policy_arn = "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
}



## Dome9 Service role 
resource "aws_iam_role" "Dome9" {
  name               = "${element(split("-", var.org),0)}-Dome9-service-role"

  assume_role_policy = <<EOF
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

resource "aws_iam_role_policy_attachment" "Dome9_Readonly_policy_attachment" {
    role       = "${aws_iam_role.Dome9.name}"
    policy_arn = "${aws_iam_policy.Dome9ReadOnly.arn}"
}

resource "aws_iam_role_policy_attachment" "Dome9_ViewOnlyAccess_policy_attachment" {
    role       = "${aws_iam_role.Dome9.name}" 
    policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}



## SumoLogic Service role 
resource "aws_iam_role" "SumoLogic" {
  name               = "${element(split("-", var.org),0)}-SumoLogic-service-role"

  assume_role_policy = <<EOF
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

resource "aws_iam_role_policy_attachment" "SumoLogic_AWSConfigRole_policy_attachment" {
    role       = "${aws_iam_role.SumoLogic.name}" 
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
}


## TrendMicro Service role 
resource "aws_iam_role" "TrendMicro" {
  name               = "${element(split("-", var.org),0)}-TrendMicro-service-role"

  assume_role_policy = <<EOF
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

resource "aws_iam_role_policy_attachment" "TrendMicro_policy_attachment" {
    role       = "${aws_iam_role.TrendMicro.name}"
    policy_arn = "${aws_iam_policy.TrendMicro.arn}"
}
