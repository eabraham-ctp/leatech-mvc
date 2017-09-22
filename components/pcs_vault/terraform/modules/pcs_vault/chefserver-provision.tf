# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Vault
#
# Creates a Vault server for Platform Common Services (PCS).

# The Vault server instance, Chef server version
# Only one of this either this instance or the Chef-Solo version (next)
# will be created. This one is used if chef_server_url is populated.
resource "null_resource" "chef_server" {
  count = "${length(var.chef_server_url) > 0 ? 1 : 0}"

  connection {
    type        = "ssh"
    host        = "${element(aws_instance.vault_primary.*.private_ip, count.index)}"
    user        = "${lower(element(split("_", data.aws_ami.base.name),0)) == "ubuntu" ? "ubuntu" : "ec2-user"}"
    private_key = "${file(var.conn_user_key)}"
  }

  provisioner "chef" {
    attributes_json         = "${data.template_file.server_chef_attributes.rendered}"
    run_list                = [
      "pcs_vault::default"]
    node_name               = "${var.chef_node_name}"
    server_url              = "${var.chef_server_url}"
    fetch_chef_certificates = true
    recreate_client         = true
    user_name               = "${var.chef_user}"
    user_key                = "${file(var.chef_key)}"
    version                 = "${var.chef_version}"
  }
}
