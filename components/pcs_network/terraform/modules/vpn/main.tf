# Cloud Technology Partners, Inc. https://www.cloudtp.com
#
# Common network modules
# VPN
#
# Creates a VPN tunnel for connection to an on-premise network. Can create
# multiple, independently configured customer gateways (all associated with the
# same VPN gateway).

# VPN Gateway (AWS side of VPN tunnel); shared between all customer gateways
resource "aws_vpn_gateway" "vpn_gateway" {
  count      = "${length(var.vpn_conn_config) > 0 ? 1 : 0}"
  tags       = "${merge(
                    var.default_tags, 
                    map("Name", 
                      format("%s-%s", 
                        var.org, 
                        var.environment
                      )
                    ),
                    map("transitvpc:spoke", 
                        var.transit_vpc_spoke
                    )
                  )
                }"
}

resource "aws_vpn_gateway_attachment" "vpn_vgw_attachment" {
  count               = "${length(var.vpn_conn_config) > 0 ? 1 : 0}"
  vpc_id              = "${var.vpc_id}"
  vpn_gateway_id      = "${aws_vpn_gateway.vpn_gateway.id}"
}


# Customer Gateways (customer side of VPN tunnel)
resource "aws_customer_gateway" "customer_gateways" {
  count               = "${length(element(split("|" ,element(var.vpn_conn_config, 0 )), 1)) > 0 ? 1 : 0}"
  ip_address          = "${element(split("|" ,element(var.vpn_conn_config, count.index)), 0)}"
  bgp_asn             = "${element(split("|" ,element(var.vpn_conn_config, count.index)), 1)}"
  type                = "ipsec.1"
  tags                = "${merge(var.default_tags, map("Name", format("%s-%s-%d", var.org, var.environment, count.index + 1)))}"
}

# Connect the VPN gateway to each customer gateway
resource "aws_vpn_connection" "conns" {
  vpn_gateway_id      = "${aws_vpn_gateway.vpn_gateway.id}"
  count               = "${length(element(split("|" ,element(var.vpn_conn_config, 0 )), 1)) > 0 ? 1 : 0}"
  customer_gateway_id = "${element(aws_customer_gateway.customer_gateways.*.id, count.index)}"
  type                = "ipsec.1"
  static_routes_only  = false
  tags                = "${merge(var.default_tags, map("Name", format("%s-%s-%d", var.org, var.environment, count.index + 1)))}"
}
