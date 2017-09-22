# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# One time resources for Bootstrap Process
# Creates a VPC peering.

# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "accepter" {
  provider                  = "aws.peer"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.requester.id}"
  auto_accept               = "${var.peering_autoaccept}"

  tags = "${merge(merge(var.default_tags, map("Name", format("from-%s-to-%s-vpcpeer", var.peer_acct_profile, var.requester_profile))), map("Side", "Accepter"))}"
}