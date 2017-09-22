# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Gitlab
#
# Creates a Gitlab server for Platform Common Services (PCS).

# This data source allows us to access the AWS region
data "aws_region" "current" {
  current = true
}

# # Script to drive chef-solo runs (not used for Chef server)
# data "template_file" "provision_script" {
#   template            = "${file("${path.module}/provision.sh.tpl")}"
#   vars {
#     wrapper_cookbook  = "pcs_gitlab"
#   }
# }

# Chef attributes for provisioning, in JSON format
#

data "template_file" "server_chef_attributes" {
  template            = "${file("${path.module}/chef_attributes.json.tpl")}"
  vars {
    server_private_ip = "${aws_instance.gitlab.private_ip}"
    cluster_address   = "${aws_instance.gitlab.private_ip}"
    consul_address    = "${var.consul_address}"
    data_center       = "${var.consul_data_center}"    
    ldap_host         = "${var.ldap_host}"
    bind_dn           = "${var.bind_dn}"
    bind_password     = "${var.bind_secret}"
    base_dn           = "${var.base_dn}"
    gitlab_version    = "${var.gitlab_version}"
    organization      = "${var.org}"
    environment       = "${var.environment}"
  }
}
