# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Consul

output "instance_id" {
  value = "${aws_instance.primary.id}"
}

output "instance_address" {
  value = "${aws_instance.primary.private_ip}"
}

output "node_instances_addresses" {
  value = "${join(",", aws_instance.node.*.private_ip)}"
}

output "datacenter" {
  value = "${format("%s", data.aws_region.current.name)}"
}

output "consul_agent_sg_id" {
  value = "${aws_security_group.consul_agent.id}"
}

output "consul_cluster_sg_id" {
  value = "${aws_security_group.consul_cluster.id}"
}

