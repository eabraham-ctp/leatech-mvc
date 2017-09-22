# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Vault
#
# Creates a Vault server for Platform Common Services (PCS).

# This data source allows us to access the AWS region
data "aws_region" "current" {
  current = true
}


# Chef attributes for provisioning, in JSON format
#

data "template_file" "server_chef_attributes" {
  template = "${file(format("%s/chef_attributes.json.tpl", path.module))}"
  vars {
    server_private_ip = "${aws_instance.vault_primary.private_ip}"
    consul_address    = "${var.consul_address}"
    data_center       = "${var.consul_data_center}"
    # cluster_name      = "${var.cluster_name}" doesn't seem supported
    cluster_address   = "${aws_instance.vault_primary.private_ip}"
  }
}