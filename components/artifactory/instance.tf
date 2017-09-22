# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# artifactory
#
# Creates a artifactory server (or cluster) for Platform Common Services (PCS).

# This data source allows us to access the AWS region
data "aws_region" "current" {
  current = true
}

# Use to select a random subnet from the list provided
resource "random_shuffle" "subnet" {
  keepers = {
    ami_id = "${var.ami_id}"
  }
  input = ["${var.subnet_ids}"]
  result_count = 1
}

# The (single) artifactory server instance
# TODO expand this to a cluster
resource "aws_instance" "server" {
  # Read the AMI through our random resource 'keeper' to keep the random ID constant
  # between runs, unless the AMI changes
  ami = "${random_shuffle.subnet.keepers.ami_id}"
  instance_type = "${var.instance_type}"
  key_name = "${var.conn_key_name}"
  vpc_security_group_ids = ["${aws_security_group.artifactory.id}"]
  subnet_id = "${random_shuffle.subnet.result.0}"
  tags = "${merge(var.default_tags, map("Name", format("%s-Artifactory-%s-App", var.org, var.environment)))}"

  connection {
    type = "ssh"
    user = "${var.conn_user_name}"
    private_key = "${file(var.conn_user_key)}"
  }

  provisioner "chef" {
    attributes_json = <<-EOF
      {
        "artifactory": {
          "enable_webui": true,
          "config": {
            "datacenter": "${data.aws_region.current.name}",
            "server": true,
            "encrypt": "tif3NuFR0Og2s5vAtkUYWw==",
            "bootstrap": ${var.bootstrap ? "true" : "false"}
          }
        }
      }
    EOF
    run_list = ["pcs_artifactory::default"]
    node_name = "${var.chef_node_name}"
    server_url = "${var.chef_server_url}"
    fetch_chef_certificates = true
    recreate_client = true
    user_name = "${var.chef_user}"
    user_key = "${file(var.chef_key)}"
    version = "${var.chef_version}"
  }
}
