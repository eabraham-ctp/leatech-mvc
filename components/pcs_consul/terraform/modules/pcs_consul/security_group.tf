# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Consul
#
# Creates a Consul server (or cluster) for Platform Common Services (PCS).

###############################################
#
# Consul Cluster Communication Security Group
#
resource "aws_security_group" "consul_cluster" {
  name        = "${var.org}-${var.environment}-Consul-Cluster-SG"
  description = "Consul internal traffic, administration, and UI"
  vpc_id      = "${var.vpc_id}"
  tags        = "${merge(var.default_tags, map("Name", format("%s-%s-Consul-Cluster-SG", var.org, var.environment)))}"
}
  
  
###############################################
# Ingress - Global
###############################################

# DNS TCP
resource "aws_security_group_rule" "consul_cluster_inbound_dns_tcp" {
  type              = "ingress"
  from_port         = 8600
  to_port           = 8600
  protocol          = "tcp"
  security_group_id = "${aws_security_group.consul_cluster.id}"
  cidr_blocks       = [ "${var.vpc_cidr}" ]
}

# DNS UDP
resource "aws_security_group_rule" "consul_cluster_inbound_dns_udp" {
  type              = "ingress"
  from_port         = 8600
  to_port           = 8600
  protocol          = "udp"
  security_group_id = "${aws_security_group.consul_cluster.id}"
  cidr_blocks       = [ "${var.vpc_cidr}" ]
}

# API and web UI TCP
resource "aws_security_group_rule" "consul_cluster_inbound_web_tcp" {
  type              = "ingress"
  from_port         = 8500
  to_port           = 8500
  protocol          = "tcp"
  security_group_id = "${aws_security_group.consul_cluster.id}"
  cidr_blocks       = [ "${var.vpc_cidr}" ]
}


resource "aws_security_group_rule" "consul_cluster_inbound_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.consul_cluster.id}"
  source_security_group_id = "${var.ssh_sg}" # access from open VPN clients
}

resource "aws_security_group_rule" "consul_cluster_outbound_ssh" {
  type              = "egress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = "${aws_security_group.consul_cluster.id}"
  security_group_id = "${var.ssh_sg}" # access from open VPN clients
}
 

resource "aws_security_group_rule" "consul_cluster_ingress_in_from_sec_services_sg" {
  type              = "ingress"
  from_port         = 8500
  to_port           = 8500
  protocol          = "tcp"
  security_group_id = "${aws_security_group.consul_cluster.id}"
  source_security_group_id = "${var.sec_service_sg}" 
}




###############################################
#
# Consul Agent Communication Security Group
#

resource "aws_security_group" "consul_agent" {
  name        = "${var.org}-${var.environment}-Consul-Agent-SG"
  description = "Consul internal traffic, administration, and UI"
  vpc_id      = "${var.vpc_id}"
  tags        = "${merge(var.default_tags, map("Name", format("%s-%s-Consul-Agent-SG", var.org, var.environment)))}"
}

# Server Communication TCP
resource "aws_security_group_rule" "consul_cluster_inbound_server_tcp" {
  type              = "ingress"
  from_port         = 8300
  to_port           = 8300
  protocol          = "tcp"
  security_group_id = "${aws_security_group.consul_agent.id}"
  self              = true
  depends_on        = ["aws_security_group.consul_agent"]
}

# Server Communication UDP
resource "aws_security_group_rule" "consul_cluster_inbound_server_udp" {
  type              = "ingress"
  from_port         = 8300
  to_port           = 8300
  protocol          = "udp"
  security_group_id = "${aws_security_group.consul_agent.id}"
  self              = true
  depends_on        = ["aws_security_group.consul_agent"]  
}

###############################################
# Serf Lan Communication

# Serf Lan Communication UDP
resource "aws_security_group_rule" "consul_agent_self_serf_lan_udp" {
  type              = "ingress"
  from_port         = 8301
  to_port           = 8301
  protocol          = "udp"
  security_group_id = "${aws_security_group.consul_agent.id}"
  self              = true
  depends_on        = ["aws_security_group.consul_agent"]  
}

# Serf Lan Communication TCP
resource "aws_security_group_rule" "consul_agent_self_serf_lan_tcp" {
  type              = "ingress"
  from_port         = 8301
  to_port           = 8301
  protocol          = "tcp"
  security_group_id = "${aws_security_group.consul_agent.id}"
  self              = true
  depends_on        = ["aws_security_group.consul_agent"]  
}


###############################################
# Serf Wan Communication

# Serf Wan Communication UDP
resource "aws_security_group_rule" "consul_agent_self_serf_wan_udp" {
  type              = "ingress"
  from_port         = 8302
  to_port           = 8302
  protocol          = "udp"
  security_group_id = "${aws_security_group.consul_agent.id}"
  self              = true
  depends_on        = ["aws_security_group.consul_agent"]  
}

# Serf Wan Communication TCP
resource "aws_security_group_rule" "consul_agent_self_serf_wan_tcp" {
  type              = "ingress"
  from_port         = 8302
  to_port           = 8302
  protocol          = "tcp"
  security_group_id = "${aws_security_group.consul_agent.id}"
  self              = true
  depends_on        = ["aws_security_group.consul_agent"]
}

# DNS TCP
resource "aws_security_group_rule" "consul_agent_inbound_dns_tcp" {
  type              = "ingress"
  from_port         = 8600
  to_port           = 8600
  protocol          = "tcp"
  security_group_id = "${aws_security_group.consul_cluster.id}"
  self              = true
  depends_on        = ["aws_security_group.consul_agent"]  
}

# DNS UDP
resource "aws_security_group_rule" "consul_agent_inbound_dns_udp" {
  type              = "ingress"
  from_port         = 8600
  to_port           = 8600
  protocol          = "udp"
  security_group_id = "${aws_security_group.consul_cluster.id}"
  self              = true
  depends_on        = ["aws_security_group.consul_agent"] 
}