#https://www.terraform.io/docs/providers/aws/r/route_table.html
resource "aws_route_table" "k8s" {
  ################################
  count = length(local.k8s_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  propagating_vgws = lookup(
    var.subnets.k8s, "propagating_vgws", null
  ) != null ? var.subnets.k8s.propagating_vgws : null

  tags = merge(local.tags, {
    Name = join(module.const.delimiter, [lookup(
      var.subnets.k8s, "name_prefix", null
      ) != null ? var.subnets.k8s.name_prefix : lookup(
      var.subnets, "name_prefix", null
      ) != null ? var.subnets.name_prefix : "${local.prefix}${module.const.delimiter}${var.k8s_label}",
      module.const.rtb_suffix,
    ])
  })
}

#https://www.terraform.io/docs/providers/aws/r/route.html
resource "aws_route" "k8s_default" {
  ##################################
  count = local.enable_nat_gateway

  route_table_id         = aws_route_table.k8s[0].id
  destination_cidr_block = module.const.cidr_any
  nat_gateway_id         = aws_nat_gateway.this[0].id
}

#https://www.terraform.io/docs/providers/aws/r/route_table_association.html
resource "aws_route_table_association" "k8s" {
  ############################################
  for_each = aws_subnet.k8s

  subnet_id      = each.value.id
  route_table_id = aws_route_table.k8s[0].id
}
