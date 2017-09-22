# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Vault - bootstrap

output "vault_address" {
  value = "${module.vault.instance_address}"
}

output "vault_sg_id" {
  value = "${module.vault.vault_sg_id}"
}

output "vault_iam_profile_name" {
  value = "${module.vault.instance_profile_name}"
}

output "vault_url" {
  value = "http://${module.vault.instance_address}:8200"
}

output "vault_cluster_name" {
  value = "${var.cluster_name}"
}