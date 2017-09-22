# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Vault
#
# Creates a Vault server for Platform Common Services (PCS).

# The Vault server instance, Chef server version
# Only one of this either this instance or the Chef-Solo version (next)
# will be created. This one is used if chef_server_url is populated.
resource "aws_instance" "vault_primary" {
  # Read the AMI through our random resource 'keeper' to keep the random ID constant
  # between runs, unless the AMI changes
  ami                    = "${var.ami_id}"
  instance_type          = "${var.instance_type}"
  key_name               = "${var.conn_key_name}"
  vpc_security_group_ids = ["${concat(
                                    list(aws_security_group.vault.id),
                                         var.vpc_security_group_ids
                                  )
                             }"]                            
  subnet_id              = "${var.subnet_id}"
  iam_instance_profile   = "${aws_iam_instance_profile.vault_instance_profile.name}"
  tags                   = "${merge(var.default_tags, map("Name", format("%s-%s-Vault-Master-EC2", var.org, var.environment)))}"
}

