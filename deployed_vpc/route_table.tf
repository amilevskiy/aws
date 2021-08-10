#https://www.terraform.io/docs/providers/aws/r/route_table.html
resource "aws_route_table" "this" {
  #################################
  for_each = toset(local.subnets_order)

  vpc_id = var.vpc_id

  propagating_vgws = var.subnets[each.key].propagating_vgws != null ? (
    var.subnets[each.key].propagating_vgws
  ) : var.subnets.propagating_vgws

  tags = merge(local.tags, {
    Name = join(module.const.delimiter, [var.subnets[each.key].name_prefix != null ? (
      var.subnets[each.key].name_prefix
      ) : var.subnets.name_prefix != null ? var.subnets.name_prefix : join(module.const.delimiter, [
        local.prefix,
        var.label[each.key]
      ]),
      module.const.rtb_suffix,
    ])
  })

  lifecycle {
    ignore_changes = [route]
  }
}

#https://www.terraform.io/docs/providers/aws/r/route_table_association.html
resource "aws_route_table_association" "this" {
  #############################################
  for_each = aws_subnet.this

  subnet_id      = each.value.id
  route_table_id = aws_route_table.this[replace(each.key, "/-.*/", "")].id
}


#https://www.terraform.io/docs/providers/aws/r/route.html
resource "aws_route" "default_for_public" {
  #########################################
  count = local.enable_internet_gateway > 0 && contains(local.subnets_order, "public") ? 1 : 0

  route_table_id         = aws_route_table.this["public"].id
  destination_cidr_block = module.const.cidr_any
  gateway_id             = aws_internet_gateway.this[0].id
}

#https://www.terraform.io/docs/providers/aws/r/route.html
resource "aws_route" "default_for_private" {
  ##########################################
  for_each = toset(local.enable_nat_gateway > 0 ? [
    for v in local.subnets_order : v if !contains(["public", "secured"], v)
  ] : [])

  route_table_id         = aws_route_table.this[each.key].id
  destination_cidr_block = module.const.cidr_any
  nat_gateway_id         = aws_nat_gateway.this[0].id
}


#https://www.terraform.io/docs/providers/aws/r/route.html
resource "aws_route" "this" {
  ###########################
  for_each = local.routes

  route_table_id = aws_route_table.this[split(":", each.key)[0]].id

  destination_cidr_block      = can(regex("^([0-9]+\\.){3}[0-9]+/[0-9]+$", split(":", each.key)[2])) ? split(":", each.key)[2] : null
  destination_ipv6_cidr_block = can(regex("^[0-9a-f:]+/[0-9]+$", split(":", each.key)[2])) ? split(":", each.key)[2] : null
  destination_prefix_list_id  = can(regex("^pl-", split(":", each.key)[2])) ? split(":", each.key)[2] : null

  carrier_gateway_id        = can(regex("^cagw-", split(":", each.key)[1])) ? split(":", each.key)[1] : null
  egress_only_gateway_id    = can(regex("^eigw-", split(":", each.key)[1])) ? split(":", each.key)[1] : null
  gateway_id                = can(regex("^igw-", split(":", each.key)[1])) ? split(":", each.key)[1] : null
  instance_id               = can(regex("^i-", split(":", each.key)[1])) ? split(":", each.key)[1] : null
  local_gateway_id          = can(regex("^lgw-", split(":", each.key)[1])) ? split(":", each.key)[1] : null
  nat_gateway_id            = can(regex("^nat-", split(":", each.key)[1])) ? split(":", each.key)[1] : null
  network_interface_id      = can(regex("^eni-", split(":", each.key)[1])) ? split(":", each.key)[1] : null
  transit_gateway_id        = can(regex("^tgw-", split(":", each.key)[1])) ? split(":", each.key)[1] : null
  vpc_endpoint_id           = can(regex("^vpce-", split(":", each.key)[1])) ? split(":", each.key)[1] : null
  vpc_peering_connection_id = can(regex("^pcx-", split(":", each.key)[1])) ? split(":", each.key)[1] : null

  depends_on = [aws_route_table.this]
}
