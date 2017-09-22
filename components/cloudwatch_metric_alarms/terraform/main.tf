# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# CIS 3.x CloudWatch Metrics & Alarms

provider "aws" {
  region = "${var.region}"
}

module "alert-topic" {
  source                  = "./modules/alert_topic"
}

output "topic_arn" {
  value = "${module.alert-topic.topic_arn}"
}

module "unuatorhized-api-calls" {
  source                          = "./modules/cloudwatch_metrics_alarms"
  alert_topic                     = "${module.alert-topic.topic_arn}"
  metric_name                     = "unuatorhized-api-calls"
  metric_pattern                  = "{ ($.errorCode = \"*UnauthorizedOperation\") || ($.errorCode = \"AccessDenied*\") }" 
  cloudtrail_logs_group           = "${var.cloudtrail_logs_group}"
  metric_transformation_name      = "UnauthorizedAPICalls"
  metric_transformation_namespace = "CIS3XMetrics"
  metric_transformation_value     = "1"
  alarm_name                      = "unuatorhized-api-calls"
  alarm_comparison_operator       = "GreaterThanOrEqualToThreshold"
  alarm_evaluation_periods        = "1"
  alarm_period                    = "120"
  alarm_statistic                 = "Sum"
  alarm_threshold                 = "1"
  alarm_description               = "This metric monitors unauthorized API calls"
  alarm_treat_missing_data        = "notBreaching" 
  alarm_insufficient_action       = []
}

output "unuatorhized-api-calls_filter" {
  value = "${module.unuatorhized-api-calls.filter_id}"
}

output "unuatorhized-api-calls_alarm" {
  value = "${module.unuatorhized-api-calls.alarm_id}"
}

module "consolenomfa" {
  source                          = "./modules/cloudwatch_metrics_alarms"
  alert_topic                     = "${module.alert-topic.topic_arn}"
  metric_name                     = "consolenomfa"
  metric_pattern                  = "{ ( $.eventName = ConsoleLogin ) && ( $.additionalEventData.MFAUsed != Yes ) }"
  cloudtrail_logs_group           = "${var.cloudtrail_logs_group}"
  metric_transformation_name      = "ConsoleSignInWithoutMfaCount"
  metric_transformation_namespace = "CIS3XMetrics"
  metric_transformation_value     = "1"
  alarm_name                      = "consolenomfa"
  alarm_comparison_operator       = "GreaterThanOrEqualToThreshold"
  alarm_evaluation_periods        = "1"
  alarm_period                    = "120"
  alarm_statistic                 = "Sum"
  alarm_threshold                 = "1"
  alarm_description               = "This metric monitors Console Logins without MFA"
  alarm_treat_missing_data        = "notBreaching" 
  alarm_insufficient_action       = []
}

output "consolenomfa_filter" {
  value = "${module.consolenomfa.filter_id}"
}

output "consolenomfa_alarm" {
  value = "${module.consolenomfa.alarm_id}"
}

module "rootaccountusage" {
  source                          = "./modules/cloudwatch_metrics_alarms"
  alert_topic                     = "${module.alert-topic.topic_arn}"
  metric_name                     = "rootaccountusage"
  metric_pattern                  = "{ $.userIdentity.type = \"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != \"AwsServiceEvent\" }"
  cloudtrail_logs_group           = "${var.cloudtrail_logs_group}"
  metric_transformation_name      = "RootAccountUsage"
  metric_transformation_namespace = "CIS3XMetrics"
  metric_transformation_value     = "1"
  alarm_name                      = "rootaccountusage"
  alarm_comparison_operator       = "GreaterThanOrEqualToThreshold"
  alarm_evaluation_periods        = "1"
  alarm_period                    = "120"
  alarm_statistic                 = "Sum"
  alarm_threshold                 = "1"
  alarm_description               = "This metric monitors Root Account usaged"
  alarm_treat_missing_data        = "notBreaching" 
  alarm_insufficient_action       = []
}

output "rootaccountusage_filter" {
  value = "${module.rootaccountusage.filter_id}"
}

output "rootaccountusage_alarm" {
  value = "${module.rootaccountusage.alarm_id}"
}

module "iampolicychanges" {
  source                          = "./modules/cloudwatch_metrics_alarms"
  alert_topic                     = "${module.alert-topic.topic_arn}"
  metric_name                     = "iampolicychanges"
  metric_pattern                  = "{($.eventName=DeleteGroupPolicy)||($.eventName=DeleteRolePolicy)||($.eventName=DeleteUserPolicy)||($.eventName=PutGroupPolicy)||($.eventName=PutRolePolicy)||($.eventName=PutUserPolicy)||($.eventName=CreatePolicy)||($.eventName=DeletePolicy)||($.eventName=CreatePolicyVersion)||($.eventName=DeletePolicyVersion)||($.eventName=AttachRolePolicy)||($.eventName=DetachRolePolicy)||($.eventName=AttachUserPolicy)||($.eventName=DetachUserPolicy)||($.eventName=AttachGroupPolicy)||($.eventName=DetachGroupPolicy)}"
  cloudtrail_logs_group           = "${var.cloudtrail_logs_group}"
  metric_transformation_name      = "IAMPolicyChanges"
  metric_transformation_namespace = "CIS3XMetrics"
  metric_transformation_value     = "1"
  alarm_name                      = "iampolicychanges"
  alarm_comparison_operator       = "GreaterThanOrEqualToThreshold"
  alarm_evaluation_periods        = "1"
  alarm_period                    = "120"
  alarm_statistic                 = "Sum"
  alarm_threshold                 = "1"
  alarm_description               = "This metric monitors IAM Policy Changes"
  alarm_treat_missing_data        = "notBreaching" 
  alarm_insufficient_action       = []
}

output "iampolicychanges_filter" {
  value = "${module.iampolicychanges.filter_id}"
}

output "iampolicychanges_alarm" {
  value = "${module.iampolicychanges.alarm_id}"
}

module "cloudtrailconfigchanges" {
  source                          = "./modules/cloudwatch_metrics_alarms"
  alert_topic                     = "${module.alert-topic.topic_arn}"
  metric_name                     = "cloudtrailconfigchanges"
  metric_pattern                  = "{ ($.eventName = CreateTrail) || ($.eventName = UpdateTrail) || ($.eventName = DeleteTrail) || ($.eventName = StartLogging) || ($.eventName = StopLogging) }"
  cloudtrail_logs_group           = "${var.cloudtrail_logs_group}"
  metric_transformation_name      = "CloudTrailChanges"
  metric_transformation_namespace = "CIS3XMetrics"
  metric_transformation_value     = "1"
  alarm_name                      = "cloudtrailconfigchanges"
  alarm_comparison_operator       = "GreaterThanOrEqualToThreshold"
  alarm_evaluation_periods        = "1"
  alarm_period                    = "120"
  alarm_statistic                 = "Sum"
  alarm_threshold                 = "1"
  alarm_description               = "This metric monitors CloudTrail Changes"
  alarm_treat_missing_data        = "notBreaching" 
  alarm_insufficient_action       = []
}

output "cloudtrailconfigchanges_filter" {
  value = "${module.cloudtrailconfigchanges.filter_id}"
}

output "cloudtrailconfigchanges_alarm" {
  value = "${module.cloudtrailconfigchanges.alarm_id}"
}

module "mgtconsolefailures" {
  source                          = "./modules/cloudwatch_metrics_alarms"
  alert_topic                     = "${module.alert-topic.topic_arn}"
  metric_name                     = "mgtconsolefailures"
  metric_pattern                  = "{ ($.eventName = ConsoleLogin) && ($.errorMessage = \"Failed authentication\") } "
  cloudtrail_logs_group           = "${var.cloudtrail_logs_group}"
  metric_transformation_name      = "ConsoleAuthenticationFailures"
  metric_transformation_namespace = "CIS3XMetrics"
  metric_transformation_value     = "1"
  alarm_name                      = "mgtconsolefailures"
  alarm_comparison_operator       = "GreaterThanOrEqualToThreshold"
  alarm_evaluation_periods        = "1"
  alarm_period                    = "120"
  alarm_statistic                 = "Sum"
  alarm_threshold                 = "1"
  alarm_description               = "This metric monitors Management Console Failures"
  alarm_treat_missing_data        = "notBreaching" 
  alarm_insufficient_action       = []
}

output "mgtconsolefailures_filter" {
  value = "${module.mgtconsolefailures.filter_id}"
}

output "mgtconsolefailures_alarm" {
  value = "${module.mgtconsolefailures.alarm_id}"
}

module "scheduledcmkdeletion" {
  source                          = "./modules/cloudwatch_metrics_alarms"
  alert_topic                     = "${module.alert-topic.topic_arn}"
  metric_name                     = "scheduledcmkdeletion"
  metric_pattern                  = "{($.eventSource = kms.amazonaws.com) && (($.eventName=DisableKey)||($.eventName=ScheduleKeyDeletion))}"
  cloudtrail_logs_group           = "${var.cloudtrail_logs_group}"
  metric_transformation_name      = "ScheduledCMKDeletion"
  metric_transformation_namespace = "CIS3XMetrics"
  metric_transformation_value     = "1"
  alarm_name                      = "scheduledcmkdeletion"
  alarm_comparison_operator       = "GreaterThanOrEqualToThreshold"
  alarm_evaluation_periods        = "1"
  alarm_period                    = "120"
  alarm_statistic                 = "Sum"
  alarm_threshold                 = "1"
  alarm_description               = "This metric monitors scheduled CMK deletion"
  alarm_treat_missing_data        = "notBreaching" 
  alarm_insufficient_action       = []
}

output "scheduledcmkdeletion_filter" {
  value = "${module.scheduledcmkdeletion.filter_id}"
}

output "scheduledcmkdeletion_alarm" {
  value = "${module.scheduledcmkdeletion.alarm_id}"
}

module "bucketpolicychanges" {
  source                          = "./modules/cloudwatch_metrics_alarms"
  alert_topic                     = "${module.alert-topic.topic_arn}"
  metric_name                     = "bucketpolicychanges"
  metric_pattern                  = "{ ($.eventSource = s3.amazonaws.com) && (($.eventName = PutBucketAcl) || ($.eventName = PutBucketPolicy) || ($.eventName = PutBucketCors) || ($.eventName = PutBucketLifecycle) || ($.eventName = PutBucketReplication) || ($.eventName = DeleteBucketPolicy) || ($.eventName = DeleteBucketCors) || ($.eventName = DeleteBucketLifecycle) || ($.eventName = DeleteBucketReplication)) }"
  cloudtrail_logs_group           = "${var.cloudtrail_logs_group}"
  metric_transformation_name      = "BucketPolicyChanges"
  metric_transformation_namespace = "CIS3XMetrics"
  metric_transformation_value     = "1"
  alarm_name                      = "bucketpolicychanges"
  alarm_comparison_operator       = "GreaterThanOrEqualToThreshold"
  alarm_evaluation_periods        = "1"
  alarm_period                    = "120"
  alarm_statistic                 = "Sum"
  alarm_threshold                 = "1"
  alarm_description               = "This metric monitors bucket policy changes"
  alarm_treat_missing_data        = "notBreaching" 
  alarm_insufficient_action       = []
}

output "bucketpolicychanges_filter" {
  value = "${module.bucketpolicychanges.filter_id}"
}

output "bucketpolicychanges_alarm" {
  value = "${module.bucketpolicychanges.alarm_id}"
}

module "awsconfigchanges" {
  source                          = "./modules/cloudwatch_metrics_alarms"
  alert_topic                     = "${module.alert-topic.topic_arn}"
  metric_name                     = "awsconfigchanges"
  metric_pattern                  = "{($.eventSource = config.amazonaws.com) && (($.eventName=StopConfigurationRecorder)||($.eventName=DeleteDeliveryChannel)||($.eventName=PutDeliveryChannel)||($.eventName=PutConfigurationRecorder))}"
  cloudtrail_logs_group           = "${var.cloudtrail_logs_group}"
  metric_transformation_name      = "AWSConfigChanges"
  metric_transformation_namespace = "CIS3XMetrics"
  metric_transformation_value     = "1"
  alarm_name                      = "awsconfigchanges"
  alarm_comparison_operator       = "GreaterThanOrEqualToThreshold"
  alarm_evaluation_periods        = "1"
  alarm_period                    = "120"
  alarm_statistic                 = "Sum"
  alarm_threshold                 = "1"
  alarm_description               = "This metric monitors config changes"
  alarm_treat_missing_data        = "notBreaching" 
  alarm_insufficient_action       = []
}

output "awsconfigchanges_filter" {
  value = "${module.awsconfigchanges.filter_id}"
}

output "awsconfigchanges_alarm" {
  value = "${module.awsconfigchanges.alarm_id}"
}

module "securitygroupchanges" {
  source                          = "./modules/cloudwatch_metrics_alarms"
  alert_topic                     = "${module.alert-topic.topic_arn}"
  metric_name                     = "securitygroupchanges"
  metric_pattern                  = "{ ($.eventName = AuthorizeSecurityGroupIngress) || ($.eventName = AuthorizeSecurityGroupEgress) || ($.eventName = RevokeSecurityGroupIngress) || ($.eventName = RevokeSecurityGroupEgress) || ($.eventName = CreateSecurityGroup) || ($.eventName = DeleteSecurityGroup)}"
  cloudtrail_logs_group           = "${var.cloudtrail_logs_group}"
  metric_transformation_name      = "SecurityGroupChanges"
  metric_transformation_namespace = "CIS3XMetrics"
  metric_transformation_value     = "1"
  alarm_name                      = "securitygroupchanges"
  alarm_comparison_operator       = "GreaterThanOrEqualToThreshold"
  alarm_evaluation_periods        = "1"
  alarm_period                    = "120"
  alarm_statistic                 = "Sum"
  alarm_threshold                 = "1"
  alarm_description               = "This metric monitors security group changes"
  alarm_treat_missing_data        = "notBreaching" 
  alarm_insufficient_action       = []
}

output "securitygroupchanges_filter" {
  value = "${module.securitygroupchanges.filter_id}"
}

output "securitygroupchanges_alarm" {
  value = "${module.securitygroupchanges.alarm_id}"
}

module "naclchanges" {
  source                          = "./modules/cloudwatch_metrics_alarms"
  alert_topic                     = "${module.alert-topic.topic_arn}"
  metric_name                     = "naclchanges"
  metric_pattern                  = "{ ($.eventName = CreateNetworkAcl) || ($.eventName = CreateNetworkAclEntry) || ($.eventName = DeleteNetworkAcl) || ($.eventName = DeleteNetworkAclEntry) || ($.eventName = ReplaceNetworkAclEntry) || ($.eventName = ReplaceNetworkAclAssociation) }"
  cloudtrail_logs_group           = "${var.cloudtrail_logs_group}"
  metric_transformation_name      = "NACLChanges"
  metric_transformation_namespace = "CIS3XMetrics"
  metric_transformation_value     = "1"
  alarm_name                      = "naclchanges"
  alarm_comparison_operator       = "GreaterThanOrEqualToThreshold"
  alarm_evaluation_periods        = "1"
  alarm_period                    = "120"
  alarm_statistic                 = "Sum"
  alarm_threshold                 = "1"
  alarm_description               = "This metric monitors nacl changes"
  alarm_treat_missing_data        = "notBreaching" 
  alarm_insufficient_action       = []
}

output "naclchanges_filter" {
  value = "${module.naclchanges.filter_id}"
}

output "naclchanges_alarm" {
  value = "${module.naclchanges.alarm_id}"
}

module "networkgatewaychanges" {
  source                          = "./modules/cloudwatch_metrics_alarms"
  alert_topic                     = "${module.alert-topic.topic_arn}"
  metric_name                     = "networkgatewaychanges"
  metric_pattern                  = "{ ($.eventName = CreateCustomerGateway) || ($.eventName = DeleteCustomerGateway) || ($.eventName = AttachInternetGateway) || ($.eventName = CreateInternetGateway) || ($.eventName = DeleteInternetGateway) || ($.eventName = DetachInternetGateway) }"
  cloudtrail_logs_group           = "${var.cloudtrail_logs_group}"
  metric_transformation_name      = "NetworkGatewayChanges"
  metric_transformation_namespace = "CIS3XMetrics"
  metric_transformation_value     = "1"
  alarm_name                      = "networkgatewaychanges"
  alarm_comparison_operator       = "GreaterThanOrEqualToThreshold"
  alarm_evaluation_periods        = "1"
  alarm_period                    = "120"
  alarm_statistic                 = "Sum"
  alarm_threshold                 = "1"
  alarm_description               = "This metric monitors network gateway changes"
  alarm_treat_missing_data        = "notBreaching" 
  alarm_insufficient_action       = []
}

output "networkgatewaychanges_filter" {
  value = "${module.networkgatewaychanges.filter_id}"
}

output "networkgatewaychanges_alarm" {
  value = "${module.networkgatewaychanges.alarm_id}"
}

module "routetablechanges" {
  source                          = "./modules/cloudwatch_metrics_alarms"
  alert_topic                     = "${module.alert-topic.topic_arn}"
  metric_name                     = "routetablechanges"
  metric_pattern                  = "{ ($.eventName = CreateRoute) || ($.eventName = CreateRouteTable) || ($.eventName = ReplaceRoute) || ($.eventName = ReplaceRouteTableAssociation) || ($.eventName = DeleteRouteTable) || ($.eventName = DeleteRoute) || ($.eventName = DisassociateRouteTable) }"
  cloudtrail_logs_group           = "${var.cloudtrail_logs_group}"
  metric_transformation_name      = "RouteTableChanges"
  metric_transformation_namespace = "CIS3XMetrics"
  metric_transformation_value     = "1"
  alarm_name                      = "routetablechanges"
  alarm_comparison_operator       = "GreaterThanOrEqualToThreshold"
  alarm_evaluation_periods        = "1"
  alarm_period                    = "120"
  alarm_statistic                 = "Sum"
  alarm_threshold                 = "1"
  alarm_description               = "This metric monitors route table changes"
  alarm_treat_missing_data        = "notBreaching" 
  alarm_insufficient_action       = []
}

output "routetablechanges_filter" {
  value = "${module.routetablechanges.filter_id}"
}

output "routetablechanges_alarm" {
  value = "${module.routetablechanges.alarm_id}"
}

module "vpcchanges" {
  source                          = "./modules/cloudwatch_metrics_alarms"
  alert_topic                     = "${module.alert-topic.topic_arn}"
  metric_name                     = "vpcchanges"
  metric_pattern                  = "{ ($.eventName = CreateVpc) || ($.eventName = DeleteVpc) || ($.eventName = ModifyVpcAttribute) || ($.eventName = AcceptVpcPeeringConnection) || ($.eventName = CreateVpcPeeringConnection) || ($.eventName = DeleteVpcPeeringConnection) || ($.eventName = RejectVpcPeeringConnection) || ($.eventName = AttachClassicLinkVpc) || ($.eventName = DetachClassicLinkVpc) || ($.eventName = DisableVpcClassicLink) || ($.eventName = EnableVpcClassicLink) }"
  cloudtrail_logs_group           = "${var.cloudtrail_logs_group}"
  metric_transformation_name      = "VPCChanges"
  metric_transformation_namespace = "CIS3XMetrics"
  metric_transformation_value     = "1"
  alarm_name                      = "vpcchanges"
  alarm_comparison_operator       = "GreaterThanOrEqualToThreshold"
  alarm_evaluation_periods        = "1"
  alarm_period                    = "120"
  alarm_statistic                 = "Sum"
  alarm_threshold                 = "1"
  alarm_description               = "This metric monitors vpc changes"
  alarm_treat_missing_data        = "notBreaching" 
  alarm_insufficient_action       = []
}

output "vpcchanges_filter" {
  value = "${module.vpcchanges.filter_id}"
}

output "vpcchanges_alarm" {
  value = "${module.vpcchanges.alarm_id}"
}
