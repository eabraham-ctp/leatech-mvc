# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# Application Instance Security groups
#

resource "aws_security_group" "talend_cluster_sg" {
  name        = "${var.org}-${var.environment}-${var.app_name}-Cluster-SG"
  description = "Application tier security group"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  tags        = "${merge(var.default_tags, map("Name", format("%s-%s-%s-Cluster-SG", var.org, var.environment, var.app_name)))}"

}
###############################################
# Talend cluster Access - Global
###############################################

resource "aws_security_group_rule" "egress_from_cluster_sg" {
  count                     = "${length(var.cluster_sg_map)}"
  type                      = "egress"
  from_port                 = "${
                                  element(
                                    split(
                                      "|",
                                      element(
                                        var.cluster_sg_map, 
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
                                        var.cluster_sg_map, 
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
                                        var.cluster_sg_map, 
                                        count.index
                                      )
                                    ),
                                    "2"
                                  )
                                }"
  self                      = true                                 
  security_group_id         = "${aws_security_group.talend_cluster_sg.id}"
}

resource "aws_security_group_rule" "ingress_to_cluster_sg" {
  count                     = "${length(var.cluster_sg_map)}"
  type                      = "ingress"
  from_port                 = "${
                                  element(
                                    split(
                                      "|",
                                      element(
                                        var.cluster_sg_map, 
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
                                        var.cluster_sg_map, 
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
                                        var.cluster_sg_map, 
                                        count.index
                                      )
                                    ),
                                    "2"
                                  )
                                }"  
  self                      = true 
  security_group_id         = "${aws_security_group.talend_cluster_sg.id}"
}
