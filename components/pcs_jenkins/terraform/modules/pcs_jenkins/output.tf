# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Jenkins - Output
#
# Module for creating the Jenkins Service for Platform Common Services (PCS). This version uses
# Chef cookbooks on top of the Terraform scripts

output "instance_id" {
  value = "${aws_instance.master.id}"
}

output "pub_address" {
  value = "${aws_instance.master.public_dns}"
}

output "priv_address" {
  value = "${aws_instance.master.private_ip}"
}

output "security_group_id" {
  value = "${aws_security_group.jenkins_master_sg.id}"
}

output "elb_address" {
  value = "${aws_elb.jenkins_master_elb.dns_name}"
}
