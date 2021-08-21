#https://www.terraform.io/docs/providers/aws/r/route_table.html
resource "aws_route_table" "this" {
  #################################
  count = local.enable_route_table

  vpc_id = var.vpc_id

  propagating_vgws = var.route_table.propagating_vgws

  tags = merge(local.tags, {
    Name = join(module.const.delimiter, compact([
      "RT",
      local.tf_stack
    ]))
  })
}

#https://www.terraform.io/docs/providers/aws/r/route_table_association.html
resource "aws_route_table_association" "this" {
  #############################################
  for_each = local.enable_route_table > 0 ? aws_subnet.this : {}

  subnet_id      = each.value.id
  route_table_id = aws_route_table.this[0].id
}

#https://www.terraform.io/docs/providers/aws/r/vpc_endpoint_route_table_association.html
resource "aws_vpc_endpoint_route_table_association" "this" {
  ##########################################################
  for_each = local.enable_route_table > 0 && var.vpc_endpoint_type_gateway_ids != null ? var.vpc_endpoint_type_gateway_ids : {}

  route_table_id  = aws_route_table.this[0].id
  vpc_endpoint_id = each.value
}



#https://www.terraform.io/docs/providers/aws/r/route.html
resource "aws_route" "this" {
  ###########################
  for_each = local.routes

  route_table_id = aws_route_table.this[0].id

  destination_cidr_block      = can(regex("^([0-9]+\\.){3}[0-9]+/[0-9]+$", each.key)) ? each.key : null
  destination_ipv6_cidr_block = can(regex("^[0-9a-f:]+/[0-9]+$", each.key)) ? each.key : null
  destination_prefix_list_id  = can(regex("^pl-", each.key)) ? each.key : null

  carrier_gateway_id        = can(regex("^cagw-", each.value)) ? each.value : null
  egress_only_gateway_id    = can(regex("^eigw-", each.value)) ? each.value : null
  gateway_id                = can(regex("^igw-", each.value)) ? each.value : null
  instance_id               = can(regex("^i-", each.value)) ? each.value : null
  local_gateway_id          = can(regex("^lgw-", each.value)) ? each.value : null
  nat_gateway_id            = can(regex("^nat-", each.value)) ? each.value : null
  network_interface_id      = can(regex("^eni-", each.value)) ? each.value : null
  transit_gateway_id        = can(regex("^tgw-", each.value)) ? each.value : null
  vpc_endpoint_id           = can(regex("^vpce-", each.value)) ? each.value : null
  vpc_peering_connection_id = can(regex("^pcx-", each.value)) ? each.value : null
}
