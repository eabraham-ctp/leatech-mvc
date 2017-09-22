# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Consul - bootstrap

output "consul_address" {
  value = "${module.pcs_consul.instance_address}"
}

output "consul_address_url" {
  value = "http://${module.pcs_consul.instance_address}:8500"
}

output "consul_node_list" {
  value = ["${module.pcs_consul.node_instances_addresses}","${compact(split(",", module.pcs_consul.node_instances_addresses))}"]
}

output "consul_data_center" {
  value = "${module.pcs_consul.datacenter}"
}

output "consul_agent_sg_id" {
  value = "${module.pcs_consul.consul_agent_sg_id}"
}

output "consul_cluster_sg_id" {
  value = "${module.pcs_consul.consul_cluster_sg_id}"
}

