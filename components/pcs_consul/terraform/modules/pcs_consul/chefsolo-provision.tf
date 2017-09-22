# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Consul
#
# Creates a primary Consul server for Platform Common Services (PCS).

# Only one of this either this instance or the Chef-server version (chefserver-provision.tf)
# will be created. This one is used if chef_server_url is not populated.

# The Consul server instance
resource "null_resource" "server_solo" {
  count = "${length(var.chef_server_url) > 0 ? 0 : 1}"

  connection {
    type        = "ssh"
    host        = "${aws_instance.primary.private_ip}"
    user        = "ec2-user"
    private_key = "${file(var.conn_user_key)}"
  }

  provisioner "file" {
    content = "${data.template_file.server_chef_attributes.rendered}"
    destination = "/tmp/chef.json"
  }

  #TECHDEBT - Copies the pcs_consul cookbook folder to the machine so we can run it locally
  provisioner "file" {
    source      = "../chef/pcs_consul"
    destination = "/var/tmp/"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo -i bash /var/tmp/pcs_consul/solo/provision.sh ${var.squid_elb_address} ${var.no_proxy}" #TECHDEBT seems a little hardcoded
    ]
  }
}


# Provision Consul Node instances
resource "null_resource" "node_solo" {
  count = "${length(var.chef_server_url) > 0 ? 0 : length(var.subnet_ids) - 1}"

  connection {
    type        = "ssh"
    host        = "${element(aws_instance.node.*.private_ip, count.index)}"
    user        = "ec2-user"
    private_key = "${file(var.conn_user_key)}"
  }

  provisioner "file" {
    content = "${data.template_file.server_chef_attributes.rendered}"
    destination = "/tmp/chef.json"
  }

  #TECHDEBT - Copies the pcs_consul cookbook folder to the machine so we can run it locally
  provisioner "file" {
    source      = "../chef/pcs_consul"
    destination = "/var/tmp/"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo -i bash /var/tmp/pcs_consul/solo/provision.sh ${var.squid_elb_address} ${var.no_proxy}" #TECHDEBT seems a little hardcoded
    ]
  }
}
