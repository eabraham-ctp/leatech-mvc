# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Application Instance Security groups
#

resource "aws_security_group" "app_sg" {
  name        = "${var.org}-${var.environment}-${var.app_name}-SG"
  description = "Application tier security group"
  vpc_id      = "${var.vpc_id}"
  tags        = "${merge(var.default_tags, map("Name", format("%s-%s-%s-SG", var.org, var.environment, var.app_name)))}"

}

###############################################
# Egress - Global
###############################################


resource "aws_security_group_rule" "egress_to_rds_sg" {
  count                     = 1
  type                      = "egress"
  from_port                 = "${var.rds_port}"
  to_port                   = "${var.rds_port}"
  protocol                  = "tcp"
  source_security_group_id  = "${var.rds_sg}"
  security_group_id         = "${aws_security_group.app_sg.id}"
}

resource "aws_security_group_rule" "ingres_from_app_sg" {
  count                     = 1
  type                      = "ingress"
  from_port                 = "${var.rds_port}"
  to_port                   = "${var.rds_port}"
  protocol                  = "tcp"
  security_group_id         = "${var.rds_sg}"
  source_security_group_id  = "${aws_security_group.app_sg.id}"
}


# Adds egress to S3 Endpoint
resource "aws_security_group_rule" "https_egress_to_vpc_s3_endpoint" {
  count                     = "${length(var.s3_endpoint_prefix_id) > 0 ? 1 : 0}" 
  type                      = "egress"
  from_port                 = "443"
  to_port                   = "443"
  protocol                  = "tcp"
  prefix_list_ids           = ["${var.s3_endpoint_prefix_id}"]
  security_group_id         = "${aws_security_group.app_sg.id}"
}

###############################################
# Access - Global
###############################################

resource "aws_security_group_rule" "egress_from_workstation_sg" {
  count                     = "${length(var.sg_map)}"
  type                      = "egress"
  from_port                 = "${
                                  element(
                                    split(
                                      "|",
                                      element(
                                        var.sg_map, 
                                        count.index
                                      )
                                    ),
                                    "0"
                                  )
                                }"
 to_port                    = "${
                                  element(
                                    split(
                                      "|",
                                      element(
                                        var.sg_map, 
                                        count.index
                                      )
                                    ),
                                    "1"
                                  )
                                }"
 protocol                   = "${
                                  element(
                                    split(
                                      "|",
                                      element(
                                        var.sg_map, 
                                        count.index
                                      )
                                    ),
                                    "2"
                                  )
                                }"  
  security_group_id         = "${var.workstation_sg}"
  source_security_group_id  = "${aws_security_group.app_sg.id}"
}

resource "aws_security_group_rule" "ingress_to_app_sg" {
  count                     = "${length(var.sg_map)}"
  type                      = "ingress"
  from_port                 = "${
                                  element(
                                    split(
                                      "|",
                                      element(
                                        var.sg_map, 
                                        count.index
                                      )
                                    ),
                                    "0"
                                  )
                                }"
 to_port                    = "${
                                  element(
                                    split(
                                      "|",
                                      element(
                                        var.sg_map, 
                                        count.index
                                      )
                                    ),
                                    "1"
                                  )
                                }"
 protocol                   = "${
                                  element(
                                    split(
                                      "|",
                                      element(
                                        var.sg_map, 
                                        count.index
                                      )
                                    ),
                                    "2"
                                  )
                                }"  
  source_security_group_id  = "${var.workstation_sg}"
  security_group_id         = "${aws_security_group.app_sg.id}"
}
