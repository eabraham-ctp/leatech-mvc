# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services

output "rds_instance_id" {
  value = "${aws_db_instance.rds.id}"
} 

output "rds_sg" {
  value = "${aws_security_group.rds_sg.id}"
}

output "rds_port" {
  value = "${aws_db_instance.rds.port}"
}

output "rds_address" {
  value = "${aws_db_instance.rds.address}"
}

output "rds_endpoint" {
  value = "${aws_db_instance.rds.endpoint}"
}

output "rds_hosted_zone_id" {
  value = "${aws_db_instance.rds.hosted_zone_id}"
}

output "rds_name" {
  value = "${aws_db_instance.rds.name}"
}
