# Cloud Technology Partners, Inc. https://www.cloudtp.com
#

output "vpc_accepter_id" {
  value = "${data.aws_caller_identity.accepter.account_id}"
}

output "vpc_requester_id" {
  value = "${aws_vpc_peering_connection.requester.id}"
}

# The status of the requester VPC Peering Connection request. 
output "requester_accept_status" {
  value = "${aws_vpc_peering_connection.requester.accept_status}"
}

# The status of the accepter VPC Peering Connection request. 
output "accepter_accept_status" {
  value = "${aws_vpc_peering_connection.requester.accept_status}"
}
 