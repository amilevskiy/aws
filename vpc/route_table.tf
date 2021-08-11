#https://www.terraform.io/docs/providers/aws/r/route_table.html
resource "aws_route_table" "this" {
  #################################
  for_each = toset(local.subnets_order)

  vpc_id = aws_vpc.this[0].id

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
resource "aws_route" "transit_gateway" {
  ######################################
  for_each = local.vpc_routes

  route_table_id = aws_route_table.this[
    split(module.const.delimiter, each.key)[0]
  ].id

  destination_cidr_block = split(module.const.delimiter, each.key)[1]

  transit_gateway_id = each.value

  lifecycle {
    ignore_changes = [state]
  }

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.this, aws_route_table.this]
}
