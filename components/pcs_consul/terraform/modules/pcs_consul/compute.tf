# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Consul
#
# Creates a primary Consul server for Platform Common Services (PCS).

# The Consul server ec2 instance
# One instance will be created.  The Server or Solo provisioner will be called
# depending on if chef_server_url is populated.

resource "aws_instance" "primary" {
  ami                    = "${var.ami_id}"
  instance_type          = "${var.instance_type}"
  key_name               = "${var.conn_key_name}"
  monitoring             = true
  vpc_security_group_ids = ["${concat(
                                    list(aws_security_group.consul_cluster.id,
                                         aws_security_group.consul_agent.id),
                                         var.vpc_security_group_ids
                                  )
                             }"]

  subnet_id              = "${var.subnet_ids[0]}"
  # Select the first Subnet ID of the list
  tags                   = "${merge(var.default_tags, map("Name", format("%s-%s-Consul-Primary-EC2", var.org, var.environment)))}"
}

# The Consul Node instance, Chef server version
# Only one of this either this instance or the Chef-Solo version (next)
# will be created. This one is used if chef_server_url is populated.
resource "aws_instance" "node" {
  count                  = "${length(var.subnet_ids) - 1}"
  # Read the AMI through our random resource 'keeper' to keep the random ID constant
  # between runs, unless the AMI changes
  ami                    = "${var.ami_id}"
  instance_type          = "${var.instance_type}"
  key_name               = "${var.conn_key_name}"
  monitoring             = true
  vpc_security_group_ids = ["${concat(
                                    list(aws_security_group.consul_cluster.id,
                                         aws_security_group.consul_agent.id),
                                         var.vpc_security_group_ids
                                  )
                             }"]
  subnet_id              = "${var.subnet_ids[count.index + 1]}"
  # Select the first Subnet ID of the list
  tags                   = "${merge(var.default_tags, map("Name", format("%s-%s-Consul-Node-EC2", var.org, var.environment)))}"
  depends_on             = ["aws_instance.primary"]
}
