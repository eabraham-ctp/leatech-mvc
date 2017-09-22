# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Workstation - bootstrap

output "devops_sg_id" {
  value = "${module.devops.devops_sg_id}"
}