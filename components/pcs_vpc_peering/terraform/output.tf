# Cloud Technology Partners, Inc. https://www.cloudtp.com
#



output "vpc_accepter_id" {
  value = "${module.pcs_vpc_peering.vpc_accepter_id}"
}

output "vpc_requester_id" {
  value = "${module.pcs_vpc_peering.vpc_requester_id}"
}

output "requester_accept_status" {
  value = "${module.pcs_vpc_peering.requester_accept_status}"
}

output "accepter_accept_status" {
  value = "${module.pcs_vpc_peering.accepter_accept_status}"
}
