# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Squid



output "squid_instance_profile" {
  description = "Instance profile which is attached to the instance which pulls down configuration from the S3 bucket"
  value       = "${module.squid_global_config.squid_instance_profile}"
}

output "squid_elb_address" {
  description = "Internal ELB dns address and port for your client machines to use"
  value       = "${module.squid_instance_config.squid_elb_address}:${var.squid_port}"
}

output "squid_elb_sg" {
  description = "ELB security group which you must allow access to from your instance/service security groups"
  value       = "${module.squid_instance_config.squid_elb_sg}"
}