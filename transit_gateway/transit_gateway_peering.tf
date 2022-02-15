variable "transit_gateway_peering" {
  type = object({
    name = optional(string)

    peer_account_id                     = optional(string)
    peer_region                         = string
    peer_transit_gateway_id             = string
    peer_transit_gateway_route_table_id = optional(string)

    static_routes = optional(map(bool))
  })

  default = null
}

locals {
  enable_transit_gateway_peering = var.enable && var.transit_gateway_peering != null ? 1 : 0

  transit_gateway_peering_name = local.enable_transit_gateway_peering > 0 ? (var.transit_gateway_peering.name != null
    ? var.transit_gateway_peering.name
    : "${local.prefix}${module.const.delimiter}${module.const.tgw_suffix}${module.const.delimiter}${module.const.tgw_peering_suffix}"
  ) : null

  transit_gateway_peering_static_routes = var.enable && var.transit_gateway != null && var.transit_gateway_peering != null ? (
    var.transit_gateway_peering.peer_transit_gateway_route_table_id != null
  ) ? var.transit_gateway_peering.static_routes != null ? var.transit_gateway_peering.static_routes : {} : {} : {}
}

#https://www.terraform.io/docs/providers/aws/r/ec2_transit_gateway_peering_attachment
resource "aws_ec2_transit_gateway_peering_attachment" "this" {
  ############################################################
  count = local.enable_transit_gateway_peering

  peer_account_id         = var.transit_gateway_peering.peer_account_id
  peer_region             = var.transit_gateway_peering.peer_region
  peer_transit_gateway_id = var.transit_gateway_peering.peer_transit_gateway_id
  transit_gateway_id      = aws_ec2_transit_gateway.this[0].id

  tags = merge(local.tags, {
    Name = local.transit_gateway_peering_name
  })

}

#https://www.terraform.io/docs/providers/aws/r/ec2_transit_gateway_peering_attachment_accepter
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "this" {
  #####################################################################
  provider = aws.peer

  count = local.enable_transit_gateway_peering

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.this[0].id

  tags = merge(local.tags, {
    Name = local.transit_gateway_peering_name
  })
}

#https://www.terraform.io/docs/providers/aws/r/ec2_transit_gateway_route
resource "aws_ec2_transit_gateway_route" "peer" {
  ###############################################
  provider = aws.peer

  for_each = local.transit_gateway_peering_static_routes

  transit_gateway_route_table_id = var.transit_gateway_peering.peer_transit_gateway_route_table_id
  destination_cidr_block         = each.key
  blackhole                      = each.value ? each.value : null
  transit_gateway_attachment_id  = each.value ? null : aws_ec2_transit_gateway_peering_attachment.this[0].id

  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.this]
}
