# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# RDS
#

resource "aws_security_group" "rds_sg" {
  name        = "${var.org}-${var.environment}-${var.app_name}-RDS-SG"
  description = "RDS security group"
  vpc_id      = "${var.vpc_id}"
  tags        = "${merge(var.default_tags, map("Name", format("%s-%s-%s-RDS-SG", var.org, var.environment, var.app_name)))}"
}
