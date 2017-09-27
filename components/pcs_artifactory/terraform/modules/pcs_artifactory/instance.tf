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
  keepers       = {
                    ami_id = "${var.ami_id}"
                  }
  input        = ["${var.subnet_ids}"]
  result_count = 1
}

# The (single) artifactory server instance
# TODO expand this to a cluster
resource "aws_instance" "artifactory_server" {
  # Read the AMI through our random resource 'keeper' to keep the random ID constant
  # between runs, unless the AMI changes
  ami                    = "${random_shuffle.subnet.keepers.ami_id}"
  instance_type          = "${var.instance_type}"
  key_name               = "${var.conn_key_name}"
  vpc_security_group_ids = ["${concat(
                                    list(aws_security_group.artifactory.id),
                                    var.vpc_security_group_ids
                                  )
                             }"]  
  subnet_id              = "${random_shuffle.subnet.result.0}"
  tags                   = "${merge(var.default_tags, map("Name", format("%s-%s-Artifactory-EC2", var.org, var.environment)))}"
}

resource "null_resource" "artifactory_server" { 
  connection {
    type                 = "ssh"
    host                 = "${element(aws_instance.artifactory_server.*.private_ip, count.index)}"
    user                 = "${var.conn_user_name}"
    private_key          = "${file(var.conn_private_key)}"
  }

  provisioner "chef" {
    attributes_json         = "${data.template_file.server_chef_attributes.rendered}"
    run_list                = ["role[base]","recipe[pcs_artifactory::default]"]
    node_name               = "artifactory"
    server_url              = "${var.chef_server_url}"
    fetch_chef_certificates = true
    recreate_client         = true
    user_name               = "${var.chef_user_name}"
    user_key                = "${file(var.chef_user_key)}" #TECHDEBT should come from vault
    http_proxy              = "${var.http_proxy}"
    https_proxy             = "${var.https_proxy}"
    no_proxy                = ["${var.no_proxy}"]
    environment             = "${lower(format("%s-%s", var.org, var.environment))}"
  }
}


# Add Cname to Route53 if available
resource "aws_route53_record" "artifactory" {
  count                   = "${length(var.route53_zone_id) > 0 ? 1 : 0}"
  zone_id                 = "${var.route53_zone_id}"
  name                    = "artifactory"
  type                    = "A"
  ttl                     = "30"
  records                 = ["${aws_instance.artifactory_server.private_ip}"]
}
