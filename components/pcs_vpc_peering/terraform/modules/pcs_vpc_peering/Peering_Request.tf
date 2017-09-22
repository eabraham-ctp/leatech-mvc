# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# One time resources for Bootstrap Process
# Creates a VPC peering.

// Requester's side of the connection.

resource "aws_vpc_peering_connection" "requester" {
  vpc_id        = "${var.vpc_id}"
  peer_vpc_id   = "${data.aws_vpc.peer_vpc.id}"
  peer_owner_id = "${data.aws_caller_identity.accepter.account_id}"
  auto_accept   = "${var.peering_autoaccept}"
  tags          = "${merge(merge(var.default_tags, map("Name", format("from-%s-to-%s-vpcpeer", var.peer_acct_profile, var.requester_profile))), map("Side", "Requester"))}"
  
  # accepter {
  #   allow_remote_vpc_dns_resolution = "${var.allow_remote_vpc_dns_resolution}"
  # }

  # requester {
  #   allow_remote_vpc_dns_resolution = "${var.allow_remote_vpc_dns_resolution}"
  # }
}

