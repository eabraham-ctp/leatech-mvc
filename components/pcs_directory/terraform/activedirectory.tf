# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Active Directory - bootstrap

# Create Simple AD
resource "aws_directory_service_directory" "mvc-ad" {
  type     = "SimpleAD"
  size     = "Small"
  name     = "${var.org}-${var.environment}.local"
  password = "${var.directory_password}"
 
  vpc_settings {
    vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
    subnet_ids = ["${data.terraform_remote_state.vpc.data_subnet_ids[0]}", "${data.terraform_remote_state.vpc.data_subnet_ids[1]}"]
  }
}
