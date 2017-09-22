# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services


output "instance_id" {
  value = "${aws_instance.app.id}"
} 

output "instance_address" {
  value = "${aws_instance.app.private_ip}"
} 
output "app_sg" {
  value = "${aws_security_group.app_sg.id}"
}
