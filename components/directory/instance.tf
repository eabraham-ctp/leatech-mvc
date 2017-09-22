# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Active Directory - bootstrap

# Default security group to access the instances via WinRM over HTTP and HTTPS
resource "aws_security_group" "sg_windows" {
  name        = "${var.org}-DirectoryJoin-${var.environment}-App"
  description = "SSH access and allow outbound internet access"
  vpc_id = "${var.vpc_id}"

  # access from anywhere
  ingress {
    from_port   = 5985
    to_port     = 5986
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(var.default_tags, map("Name", format("%s-DirectoryJoin-%s-App", var.org, var.environment)))}"
}

# Lookup the correct AMI based on the region specified
data "aws_ami" "amazon_windows_2012R2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2012-R2_RTM-English-64Bit-Base-*"]
  }
}

data "template_file" "init" {
    template = <<EOF
    <script>
      winrm quickconfig -q & winrm set winrm/config/winrs @{MaxMemoryPerShellMB="300"} & winrm set winrm/config @{MaxTimeoutms="1800000"} & winrm set winrm/config/service @{AllowUnencrypted="true"} & winrm set winrm/config/service/auth @{Basic="true"} & winrm/config @{MaxEnvelopeSizekb="8000kb"}
    </script>
    <powershell>
     netsh advfirewall firewall add rule name="WinRM in" protocol=TCP dir=in profile=any localport=5985 remoteip=any localip=any action=allow
     $admin = [ADSI]("WinNT://./Administrator, user")
     $admin.SetPassword("${var.directory_password}")
    </powershell>
EOF
    vars {
      directory_password = "${var.directory_password}"
    }
}

data "template_file" "directoryinit" {
  template = "${file("${path.module}/adscripts/directory_init.tpl")}"

  vars {
    directory_name = "${var.directory_name}",
    org = "${var.org}",
    net_bios = "${element(split(".", var.directory_name), signum(0))}",
    domain_mode = "${var.domain_mode}",
    forest_mode = "${var.forest_mode}",
    directory_admin = "${var.directory_admin}",
    directory_password = "${var.directory_password}"
  }
}

data "template_file" "addusers" {
  template = "${file("${path.module}/adscripts/directory_domain_users.tpl")}"

  vars {
    directory_name = "${var.directory_name}",
    directory_password = "${var.directory_password}"
    org = "${var.org}",
    domain = "${join(",", formatlist("DC=%s", split(".", var.directory_name)))}"
  }
}

### Windows 2012 AD Server ###
resource "aws_instance" "windows_ad_server" {
  ami           = "${data.aws_ami.amazon_windows_2012R2.image_id}"
  instance_type    = "${var.instance_type}"
  key_name         = "${var.key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.win-role-ssm-profile.name}"
  user_data        = "${data.template_file.init.rendered}"
  subnet_id      = "${var.private_subnet_ids[0]}"
  vpc_security_group_ids = ["${aws_security_group.sg_windows.id}"]
  root_block_device {
    volume_type = "gp2"
    volume_size =  50
    delete_on_termination = true
  }
  monitoring = true

  tags = "${merge(var.default_tags, map("Name", format("%s-DirectoryJoin-%s-App", var.org, var.environment)))}"

  ### Allow AWS infrastructure metadata to propagate ###
  provisioner "local-exec" {
    command = "sleep 60"
  }

  ### Copy Scripts to EC2 instance ###
  provisioner "file" {
    source      = "${path.module}/adscripts/"
    destination = "C:\\scripts"
    connection   = {
     type        = "winrm"
     user        = "${var.directory_admin}",
     password    = "${var.directory_password}"
     agent       = "false"
    }
  }

  provisioner "file" {
    content      = "${data.template_file.directoryinit.rendered}"
    destination = "C:\\scripts\\directory_init.ps1"
    connection   = {
     type        = "winrm"
     user        = "${var.directory_admin}",
     password    = "${var.directory_password}"
     agent       = "false"
    }
  }

  provisioner "file" {
    content      = "${data.template_file.addusers.rendered}"
    destination = "C:\\scripts\\directory_domain_users.ps1"
    connection   = {
     type        = "winrm"
     user        = "${var.directory_admin}",
     password    = "${var.directory_password}"
     agent       = "false"
    }
  }

  ### Set Execution Policy to Remote-Signed, Configure Active Directory ###
  provisioner "remote-exec" {
    connection = {
     type        = "winrm"
     user        = "${var.directory_admin}",
     password    = "${var.directory_password}"
     agent       = "false"
    }
    inline = [
      "powershell.exe Set-ExecutionPolicy RemoteSigned -force",
      "powershell.exe -version 4 -ExecutionPolicy Bypass -File C:\\scripts\\directory_init.ps1"
    ]
  }
}
