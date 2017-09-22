# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# artifactory
#
# Creates a artifactory server (or cluster) for Platform Common Services (PCS).

resource "aws_security_group" "artifactory" {
  name = "${var.org}-Artifactory-${var.environment}-App"
  description = "artifactory internal traffic, administration, and UI"
  vpc_id = "${var.vpc_id}"
  tags = "${merge(var.default_tags, map("Name", format("%s-Artifactory-%s-App", var.org, var.environment)))}"

  # For internal traffic (between cluster members)
  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    self = true
  }

  ingress {
    from_port = 0
    to_port = 65535
    protocol = "udp"
    self = true
  }

  # For administration
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # API and web UI
  ingress {
    from_port = 8443
    to_port = 8443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ICMP for ping
  ingress {
    protocol  = "icmp"
    from_port = 8
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  # No outbound restrictions
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

}
