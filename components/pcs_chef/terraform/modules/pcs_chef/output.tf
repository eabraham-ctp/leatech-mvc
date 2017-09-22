output "instance_id" {
  value = "${aws_instance.chef_server.id}"
}

output "pub_address" {
  value = "${aws_instance.chef_server.public_dns}"
}

output "priv_address" {
  value = "${aws_instance.chef_server.private_ip}"
}

output "chef_sg" {
  value = "${aws_security_group.chef_sg.id}"
}
output "chef_elb_sg" {
  value = "${aws_security_group.chef_elb_sg.id}"
}
output "elb_address" {
  value = "${aws_elb.chef.dns_name}"
}
