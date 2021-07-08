#https://www.terraform.io/docs/providers/aws/r/route_table.html
resource "aws_route_table" "public" {
  ###################################
  count = length(local.public_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  propagating_vgws = lookup(
    var.subnets.public, "propagating_vgws", null
    ) != null ? var.subnets.public.propagating_vgws : lookup(
    var.subnets, "propagating_vgws", null
  ) != null ? var.subnets.propagating_vgws : null

  tags = merge(var.tags, {
    Name = join(module.const.delimiter, [lookup(
      var.subnets.public, "name_prefix", null
      ) != null ? var.subnets.public.name_prefix : lookup(
      var.subnets, "name_prefix", null
      ) != null ? var.subnets.name_prefix : "${local.prefix}${module.const.delimiter}${var.public_label}",
      module.const.rtb_suffix,
    ])
  })
}

#https://www.terraform.io/docs/providers/aws/r/route.html
resource "aws_route" "public_default" {
  #####################################
  count = local.enable_internet_gateway > 0 && length(local.public_subnets) > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = module.const.cidr_any
  gateway_id             = aws_internet_gateway.this[0].id
}


#https://www.terraform.io/docs/providers/aws/r/route_table_association.html
resource "aws_route_table_association" "public" {
  ###############################################
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public[0].id
}


#https://www.terraform.io/docs/providers/aws/r/route_table.html
resource "aws_route_table" "private" {
  ####################################
  count = length(local.private_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  propagating_vgws = lookup(
    var.subnets.private, "propagating_vgws", null
  ) != null ? var.subnets.private.propagating_vgws : null

  tags = merge(var.tags, {
    Name = join(module.const.delimiter, [lookup(
      var.subnets.private, "name_prefix", null
      ) != null ? var.subnets.private.name_prefix : lookup(
      var.subnets, "name_prefix", null
      ) != null ? var.subnets.name_prefix : "${local.prefix}${module.const.delimiter}${var.private_label}",
      module.const.rtb_suffix,
    ])
  })
}

#https://www.terraform.io/docs/providers/aws/r/route.html
resource "aws_route" "private_default" {
  ######################################
  count = local.enable_nat_gateway

  route_table_id         = aws_route_table.private[0].id
  destination_cidr_block = module.const.cidr_any
  nat_gateway_id         = aws_nat_gateway.this[0].id
}

#https://www.terraform.io/docs/providers/aws/r/route_table_association.html
resource "aws_route_table_association" "private" {
  ################################################
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[0].id
}


#https://www.terraform.io/docs/providers/aws/r/route_table.html
resource "aws_route_table" "secured" {
  ####################################
  count = length(local.secured_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  propagating_vgws = lookup(
    var.subnets.secured, "propagating_vgws", null
    ) != null ? var.subnets.secured.propagating_vgws : lookup(
    var.subnets, "propagating_vgws", null
  ) != null ? var.subnets.propagating_vgws : null

  tags = merge(var.tags, {
    Name = join(module.const.delimiter, [lookup(
      var.subnets.secured, "name_prefix", null
      ) != null ? var.subnets.secured.name_prefix : lookup(
      var.subnets, "name_prefix", null
      ) != null ? var.subnets.name_prefix : "${local.prefix}${module.const.delimiter}${var.secured_label}",
      module.const.rtb_suffix,
    ])
  })
}

#https://www.terraform.io/docs/providers/aws/r/route_table_association.html
resource "aws_route_table_association" "secured" {
  ################################################
  for_each = aws_subnet.secured

  subnet_id      = each.value.id
  route_table_id = aws_route_table.secured[0].id
}
