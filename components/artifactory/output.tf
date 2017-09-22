# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# artifactory

output "instance_id" {
  value = "${aws_instance.server.id}"
}

output "instance_address" {
  value = "${aws_instance.server.private_ip}"
}
