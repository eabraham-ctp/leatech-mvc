# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Artifactory
#
# Creates a Artifactory server for Platform Common Services (PCS).

data "template_file" "server_chef_attributes" {
  template            = "${file("${path.module}/chef_attributes.json.tpl")}"
  vars {
    data_center       = "${var.consul_data_center}"    
  }
}