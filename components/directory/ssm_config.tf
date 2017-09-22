# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Active Directory - bootstrap

resource "aws_ssm_document" "mvc_ssm_document" {
   name = "ssm_document_${var.directory_name}"
   document_type = "Command"
   content = <<DOC
{
    "schemaVersion": "1.0",
    "description": "Automatic Domain Join Configuration",
    "runtimeConfig": {
        "aws:domainJoin": {
            "properties": {
                "directoryId": "${aws_directory_service_directory.mvc-ad.id}",
                "directoryName": "${var.directory_name}",
                "dnsIpAddresses": ["${aws_directory_service_directory.mvc-ad.dns_ip_addresses[0]}","${aws_directory_service_directory.mvc-ad.dns_ip_addresses[1]}"]
            }
        }
    }
}
DOC
    depends_on = ["aws_directory_service_directory.mvc-ad"]
}

resource "aws_ssm_association" "associate_ssm_web-ad-domain" {
  name       = "${aws_ssm_document.mvc_ssm_document.name}"
  instance_id = "${aws_instance.windows_ad_server.id}"
  depends_on = ["aws_ssm_document.mvc_ssm_document", "aws_instance.windows_ad_server"]
}
