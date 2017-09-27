# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# artifactory

output "instance_id" {
  value = "${aws_instance.artifactory_server.id}"
}

output "instance_address" {
  value = "${aws_instance.artifactory_server.private_ip}"
}
