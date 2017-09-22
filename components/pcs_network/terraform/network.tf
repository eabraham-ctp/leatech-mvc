# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Platform Common Services
# VPC (simple)
#
# Creates the VPC, with subnets, route tables, and other associated resources,
# for Platform Common Services (PCS). This version uses simple inbound/outbound
# subnets and routing.


# VPN connection to the VPC, this is not relevent to the VPC but IS required for routing #TECHDEBT
module "vpn" {
  source              = "modules/vpn"
  external_gw_id      = "${var.external_gw_id}"
  vpn_conn_config     = "${var.vpn_conn_config}"
  vpc_id              = "${module.vpc.vpc_id}"
  default_tags        = "${var.default_tags}"
  environment         = "${var.environment}"
  org                 = "${var.org}"
  transit_vpc_spoke   = "${var.transit_vpc_spoke}"
}

# The VPC (subnets added next)
module "vpc" {
  source              = "modules/vpc"

  vpc_name            = "${var.vpc_name}"
  vpc_cidr_block      = "${var.vpc_cidr}"
  attach_vpn_gateway  = "${length(var.vpn_conn_config)}"
  vpn_vgw_id          = "${module.vpn.vpn_gateway_id}"
  domain_name_servers = "${var.domain_name_servers}"
  domain              = "${var.domain}"
  default_tags        = "${var.default_tags}"
  environment         = "${var.environment}"
  org                 = "${var.org}"
}

# Public subnets (DMZ/BASTION)
module "dmz_subnets" {
  source             = "modules/subnets/dmz"
  subnet_name        = "DMZ"

  vpc_name           = "${module.vpc.vpc_name}"
  saml_provider      = "${var.saml_provider}"
  vpc_id             = "${module.vpc.vpc_id}"
  vpn_vgw_ids        = "${
                          list(
                            coalesce(
                                      var.external_gw_id,
                                      module.vpn.vpn_gateway_id
                                  )
                          )
                        }" 
  s3endpoint         = "${aws_vpc_endpoint.S3-Endpoint.id}"  
  subnet_cidrs       = ["${compact(
                        split(",", 
                          lookup(var.subnet_cidrs, "DMZ","")
                            )
                        )}"
                       ]
  azs                = "${var.azs}"
  default_tags       = "${var.default_tags}"
  environment        = "${var.environment}"
  org                = "${var.org}"
}
# Private subnets 
# Security
module "security_subnets" {
  source             = "modules/subnets/base_subnet"
  subnet_name        = "Security"

  static_routes      = "${var.static_routes}"
  vpc_id             = "${module.vpc.vpc_id}"
  vpc_name           = "${module.vpc.vpc_name}"
  vpn_vgw_ids        = "${
                          list(
                            coalesce(
                                      var.external_gw_id,
                                      module.vpn.vpn_gateway_id
                                  )
                          )
                        }" 
  saml_provider      = "${var.saml_provider}"
  azs                = "${var.azs}"
  nat_gateway_ids    = "${module.dmz_subnets.nat_gateway_ids}"
  default_tags       = "${var.default_tags}"
  s3endpoint         = "${aws_vpc_endpoint.S3-Endpoint.id}"  
  pcs_vpc_peering_id = "${var.pcs_vpc_peering_id}"
  pcs_vpc_cidr       = "${var.pcs_vpc_cidr}"
  pss_vpc_peering_id = "${var.pss_vpc_peering_id}"
  pss_vpc_cidr       = "${var.pss_vpc_cidr}"  
  subnet_cidrs       = ["${compact(
                          split(",", 
                            lookup(var.subnet_cidrs, "Security","")
                              )
                          )}"
                        ]
  environment        = "${var.environment}"
  org                = "${var.org}"
}

# Services
module "service_subnets" {
  source             = "modules/subnets/base_subnet"
  subnet_name        = "Services"

  static_routes      = "${var.static_routes}"
  vpc_id             = "${module.vpc.vpc_id}"
  vpc_name           = "${module.vpc.vpc_name}"
  vpn_vgw_ids        = "${
                          list(
                            coalesce(
                                      var.external_gw_id,
                                      module.vpn.vpn_gateway_id
                                  )
                          )
                        }" 
  saml_provider      = "${var.saml_provider}"
  azs                = "${var.azs}"
  nat_gateway_ids    = "${module.dmz_subnets.nat_gateway_ids}"
  default_tags       = "${var.default_tags}"
  s3endpoint         = "${aws_vpc_endpoint.S3-Endpoint.id}"  
  pcs_vpc_peering_id = "${var.pcs_vpc_peering_id}"
  pcs_vpc_cidr       = "${var.pcs_vpc_cidr}"
  pss_vpc_peering_id = "${var.pss_vpc_peering_id}"
  pss_vpc_cidr       = "${var.pss_vpc_cidr}"  
  subnet_cidrs       = ["${compact(
                          split(",", 
                            lookup(var.subnet_cidrs, "Services","")
                              )
                          )}"
                        ]

  environment        = "${var.environment}"
  org                = "${var.org}"
}

# Data
module "data_subnets" {
  source             = "modules/subnets/base_subnet"
  subnet_name        = "Data"

  static_routes      = "${var.static_routes}"
  vpc_id             = "${module.vpc.vpc_id}"
  vpc_name           = "${module.vpc.vpc_name}"
  vpn_vgw_ids        = "${
                          list(
                            coalesce(
                                      var.external_gw_id,
                                      module.vpn.vpn_gateway_id
                                  )
                          )
                        }" 
  saml_provider      = "${var.saml_provider}"
  azs                = "${var.azs}"
  nat_gateway_ids    = "${module.dmz_subnets.nat_gateway_ids}"
  default_tags       = "${var.default_tags}"
  s3endpoint         = "${aws_vpc_endpoint.S3-Endpoint.id}"  
  pcs_vpc_peering_id = "${var.pcs_vpc_peering_id}"
  pcs_vpc_cidr       = "${var.pcs_vpc_cidr}"
  pss_vpc_peering_id = "${var.pss_vpc_peering_id}"
  pss_vpc_cidr       = "${var.pss_vpc_cidr}"  
  subnet_name        = "Data"
  subnet_cidrs       = ["${compact(
                          split(",", 
                            lookup(var.subnet_cidrs, "Data","")
                              )
                          )}"
                        ]  

  environment        = "${var.environment}"
  org                = "${var.org}"
}

# Workstation Subnets for developers and DevOps
module "workstation_subnets" {
  source             = "modules/subnets/base_subnet"
  subnet_name        = "Workstations"

  static_routes      = "${var.static_routes}"
  vpc_id             = "${module.vpc.vpc_id}"
  vpc_name           = "${module.vpc.vpc_name}"
  vpn_vgw_ids        = "${
                          list(
                            coalesce(
                                      var.external_gw_id,
                                      module.vpn.vpn_gateway_id
                                  )
                          )
                        }" 
  saml_provider      = "${var.saml_provider}"
  azs                = "${var.azs}"
  nat_gateway_ids    = "${module.dmz_subnets.nat_gateway_ids}"
  default_tags       = "${var.default_tags}"
  s3endpoint         = "${aws_vpc_endpoint.S3-Endpoint.id}"  
  pcs_vpc_peering_id = "${var.pcs_vpc_peering_id}"
  pcs_vpc_cidr       = "${var.pcs_vpc_cidr}"
  pss_vpc_peering_id = "${var.pss_vpc_peering_id}"
  pss_vpc_cidr       = "${var.pss_vpc_cidr}"  
  subnet_cidrs       = ["${compact(
                          split(",", 
                            lookup(var.subnet_cidrs, "Workstations","")
                              )
                          )}"
                        ]  

  environment        = "${var.environment}"
  org                = "${var.org}"
}

# # Add the VPN route propagation to route tables - Only work in .0.10 onwards left as this is the way it should be handled 
# resource "aws_vpn_gateway_route_propagation" "vpn_route_propagation" {
#   vpn_gateway_id = "${module.vpn.vpn_gateway_id}"
#   route_table_id = "${
#       merge(
#         module.dmz_subnets.aws_route_table_ids,
#         module.security_subnets.aws_route_table_ids,
#         module.service_subnets.aws_route_table_ids,
#         module.data_subnets.aws_route_table_ids,
#         module.workstation_subnets.aws_route_table_ids,
#         module.dmz_subnets.aws_route_table_ids
#     )
#   }"
# }
