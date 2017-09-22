# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Consul
#
# Creates a primary Consul server for Platform Common Services (PCS).

# This data source allows us to access the AWS region
data "aws_region" "current" {
  current = true
}

# Chef attributes for provisioning, in JSON format
data "template_file" "server_chef_attributes" {
  template = "${file(format("%s/server_chef_attributes.json.tpl", path.module))}"
  vars {
    data_center = "${format("%s", data.aws_region.current.name)}"
    bootstrap   = "true"
  }
}

# Chef attributes for provisioning, in JSON format
data "template_file" "node_chef_attributes" {
  template = "${file(format("%s/node_chef_attributes.json.tpl", path.module))}"
  vars {
    data_center = "${format("%s", data.aws_region.current.name)}"
    bootstrap   = "false"
    ip_to_join  = "${aws_instance.primary.private_ip}"
  }
}
