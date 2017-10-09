# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Gitlab
#
# Creates a Gitlab server for Platform Common Services (PCS).

# The Gitlab server instance, Chef server version
# Only one of this either this instance or the Chef-Solo version (next)
# will be created. This one is used if chef_server_url is populated.

resource "null_resource" "chef_server" {
  count         = "${length(var.chef_server_url) > 0 ? 1 : 0}"
  connection {
    type        = "ssh"
    host        = "${element(aws_instance.gitlab.*.private_ip, count.index)}"
    user        = "${var.conn_user_name}"
    private_key = "${file(var.conn_private_key)}"
  }

  # provisioner "remote-exec" {
  #   script = "${format("%s/../../../../shared/chef-server/pre-provision.sh", path.module)}"
  # }

  provisioner "chef" {
    run_list                = ["role[base]","role[gitlab]"]
    attributes_json         = "${data.template_file.server_chef_attributes.rendered}"
    node_name               = "gitlab"
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

  # provisioner "remote-exec" {
  #   script = "${format("%s/../../../../shared/chef-server/post-provision.sh", path.module)}"
  # }
}
