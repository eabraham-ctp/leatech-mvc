# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Vault

output "instance_id" {
  value = "${aws_instance.vault_primary.id}"
}

output "instance_address" {
  value = "${aws_instance.vault_primary.private_ip}"
}

output "vault_sg_id" {
  value = "${aws_security_group.vault.id}"
}

output "instance_profile_name" {
  value = "${aws_iam_instance_profile.vault_instance_profile.name}"
}
