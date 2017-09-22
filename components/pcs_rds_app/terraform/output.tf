# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services


output "db_name" {
  value = "${module.rds.rds_name}"
}

output "rds_sg" {
  value = "${module.rds.rds_sg}"
}

output "rds_port" {
  value = "${module.rds.rds_port}"
}

output "rds_address" {
  value = "${module.rds.rds_address}"
}

output "rds_endpoint" {
  value = "${module.rds.rds_endpoint}"
}

output "rds_instance_id" {
  value = "${module.rds.rds_instance_id}"
} 

# Rstudio
output "rstudio_instance_id" {
  value = "${module.rstudio.instance_id}"
} 

output "rstudio_instance_address" {
  value = "${module.rstudio.instance_address}"
} 
output "rstudio_sg" {
  value = "${module.rstudio.app_sg}"
}
