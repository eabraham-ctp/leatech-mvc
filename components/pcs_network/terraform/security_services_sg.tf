# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Security Services
# Access control (simple)
#
# Security Services group 

###############################################
#
# Security Services Security Group
#

resource "aws_security_group" "security_services_group" {
  name              = "${var.org}-${var.environment}-SecurityServices-SG"
  description       = "Internal traffic, administration, and UI"
  vpc_id            = "${module.vpc.vpc_id}"
  tags              = "${merge(var.default_tags, map("Name", format("%s-%s-SecurityServices-SG", var.org, var.environment)))}"
}

# No rules initially the services should populate this rule set as they're stood up

###############################################
# Rules
###############################################