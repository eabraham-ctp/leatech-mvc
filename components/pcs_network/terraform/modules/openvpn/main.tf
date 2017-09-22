# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# OpenVPN
#
# Creates an OpenVPN server to allow network access to PCS when no VPN to
# a corporate data center is available


# Security group for connections and admin
resource "aws_security_group" "openvpn" {
  count         = "${length(var.openvpn_eip) > 0 ? 1 : 0}" 
  name          = "${format("%s-%s-OpenVPN-sg", var.org, var.environment)}"
  vpc_id        = "${var.vpc_id}"
  description   = "OpenVPN Access Server security group"
  tags          = "${merge(var.default_tags, map("Name", format("%s-%s-OpenVPN-sg", var.org, var.environment)))}"

  # INGRESS For OpenVPN Client Web Server & Admin Web UI [Required]
  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "udp"
    from_port   = 1194
    to_port     = 1194
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Use to select a random subnet from the public subnets
resource "random_shuffle" "subnet" {
  count                    = "${length(var.openvpn_eip) > 0 ? 1 : 0}" 
  input                    = ["${var.dmz_subnet_ids}"]
  result_count             = 1
}
 
# Single instance, publicly accessible
resource "aws_instance" "openvpn" {
  count                   = "${length(var.openvpn_eip) > 0 ? 1 : 0}" 
  ami                     = "${length(var.openvpn_ami) > 0 ? var.openvpn_ami : data.aws_ami.openvpn.id}" #TECHDEBT this doesn't work it returns you the latest 500 connected devices AMI
  subnet_id               = "${random_shuffle.subnet.result.0}"
  instance_type = "t2.medium"
  user_data = <<-EOF
    admin_user=${var.openvpn_user}
    admin_pw=${var.openvpn_password}
  EOF
  vpc_security_group_ids  = ["${concat(
                                      list(aws_security_group.openvpn.id),
                                       var.vpc_security_group_ids
                                     )
                               }"]
  key_name                = "${var.conn_key_name}"
  tags                    = "${merge(var.default_tags, map("Name", format("%s-%s-OpenVPN-EC2", var.org, var.environment)))}"
}

resource "aws_eip_association" "openvpn_eip_assoc" {
  count         = "${length(var.openvpn_eip) > 0 ? 1 : 0}" 
  instance_id   = "${aws_instance.openvpn.id}"
  allocation_id = "${data.aws_eip.openvpn_ip.id}"
}
