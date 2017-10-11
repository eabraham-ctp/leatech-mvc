# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# IAM Roles

output "developerworkstation_instance_profile_name" {
  value = "${aws_iam_instance_profile.developerworkstation_instance_profile.name}"
}
