
# Look up the most recent non-licensed AMI
data "aws_ami" "openvpn" {
  most_recent = true
  owners = ["679593333241"]

  filter {
    name = "architecture"
    values = ["x86_64"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "name"
    values = ["OpenVPN Access Server*"]
  }
}

data "aws_eip" "openvpn_ip" {
  count         = "${length(var.openvpn_eip) > 0 ? 1 : 0}" 
  public_ip     = "${var.openvpn_eip}"
}
