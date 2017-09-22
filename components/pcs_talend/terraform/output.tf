# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services

# Talend
output "talend_instance_id" {
  value = "${module.talend.instance_id}"
} 

output "talend_instance_address" {
  value = "${module.talend.instance_address}"
} 
output "talend_sg" {
  value = "${module.talend.app_sg}"
}
