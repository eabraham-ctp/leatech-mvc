# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Vault
#
# Creates a Vault server for Platform Common Services (PCS).

# The Vault server instance, Chef Solo version
# Only one of this either this instance or the Chef-server version (above)
# will be created. This one is used if chef_server_url is not populated.
resource "null_resource" "chef_solo" {
  count = "${length(var.chef_server_url) > 0 ? 0 : 1}"

  connection {
    type        = "ssh"
    host        = "${element(aws_instance.vault_primary.*.private_ip, count.index)}"
    user        = "ec2-user" #TECHDEBT hardcoding can't guess the user from the ami as they used to we currently have no use case for ubuntu
    private_key = "${file(var.conn_user_key)}"
  }

  provisioner "file" {
    content     = "${data.template_file.server_chef_attributes.rendered}"
    destination = "/tmp/chef.json"
  }

  #TECHDEBT - Copies the pcs_vault cookbook folder to the machine so we can run it locally
  provisioner "file" {
    source      = "../chef/pcs_vault"
    destination = "/var/tmp/"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo -i bash /var/tmp/pcs_vault/solo/provision.sh ${var.squid_elb_address} ${var.no_proxy}" #TECHDEBT seems a little hardcoded and should be a shared source
    ]
  }
}
