# OpenVPN security used to by modules security groups to give access to clients
output "openvpn_sg" {
  value = "${aws_security_group.openvpn.id}"
}

output "openvpn_address" {
  value = "${aws_eip_association.openvpn_eip_assoc.public_ip}"
}