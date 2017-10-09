# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# IAM Roles

#output "consul_address" {
#  value = "${module.consul.instance_address}"
#}

output "developerworkstation_instance_profile_name" {
  value = "${aws_iam_instance_profile.developerworkstation_instance_profile.name}"
}

output "emr_instance_profile_name" {
  value = "${aws_iam_instance_profile.emr_instance_profile.name}"
}

output "neo4j_instance_profile_name" {
  value = "${aws_iam_instance_profile.neo4j_instance_profile.name}"
}

output "rstudio_instance_profile_name" {
  value = "${aws_iam_instance_profile.rstudio_instance_profile.name}"
}

output "tableau_instance_profile_name" {
  value = "${aws_iam_instance_profile.tableau_instance_profile.name}"
}

output "talend_instance_profile_name" {
  value = "${aws_iam_instance_profile.talend_instance_profile.name}"
}
