locals {
  transit_gateway_vpc_attachments = local.enable_subnets ? lookup(
    var.subnets, "secured", null
    ) != null ? lookup(var.subnets.secured, "transit_gateway_vpc_attachments", null) != null ? {
    for v in var.subnets.secured.transit_gateway_vpc_attachments : v.id => v if v.id != null && v.id != ""
  } : {} : {} : {}

  route_to_tgw_list = flatten([
    for k, v in local.transit_gateway_vpc_attachments : [
      for vv in setproduct(v.vpc_routes, [k]) : join(":", vv)
    ] if v.vpc_routes != null
  ])

  vpc_routes = {
    for v in setproduct(local.subnets_order, local.route_to_tgw_list) : join(
      module.const.delimiter, [v[0], split(":", v[1])[0]]
    ) => split(":", v[1])[1]
  }

  route_to_vpc_list = flatten([
    for k, v in local.transit_gateway_vpc_attachments : [
      for vv in setproduct(
        [k],
        v.transit_gateway_static_routes != null ? v.transit_gateway_static_routes : [module.const.cidr_any],
        [v.association_default_route_table_id]
      ) : join(":", vv)
    ] if v.association_default_route_table_id != null
  ])

  transit_gateway_static_routes = {
    for v in local.route_to_vpc_list : join(":", slice(split(":", v), 0, 2)) => split(":", v)[2]
  }
}

#https://www.terraform.io/docs/providers/aws/r/ec2_transit_gateway_vpc_attachment.html
resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  ########################################################
  for_each = local.transit_gateway_vpc_attachments

  vpc_id             = aws_vpc.this[0].id
  transit_gateway_id = each.key

  subnet_ids = [
    for k, v in aws_subnet.this : v.id if can(regex("^secured-", k))
  ]

  appliance_mode_support = each.value.enable_appliance_mode_support != null ? (
    var.bool2string[each.value.enable_appliance_mode_support]
  ) : null

  dns_support = each.value.enable_dns_support != null ? (
    var.bool2string[each.value.enable_dns_support]
  ) : null

  ipv6_support = each.value.enable_ipv6_support != null ? (
    var.bool2string[each.value.enable_ipv6_support]
  ) : null

  transit_gateway_default_route_table_association = each.value.enable_default_route_table_association != null ? (
    each.value.enable_default_route_table_association
  ) : null

  transit_gateway_default_route_table_propagation = each.value.enable_default_route_table_propagation != null ? (
    each.value.enable_default_route_table_propagation
  ) : null

  #не работает! : try(each.value.name, ...
  tags = {
    Name = lookup(each.value, "name", null) != null ? each.value.name : join(module.const.delimiter, [
      local.vpc_name, each.key, module.const.tgw_attachment_suffix
    ])
  }
}

#https://www.terraform.io/docs/providers/aws/r/ec2_transit_gateway_route.html
resource "aws_ec2_transit_gateway_route" "this" {
  ###############################################
  for_each = local.transit_gateway_static_routes

  destination_cidr_block         = split(":", each.key)[1]
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this[split(":", each.key)[0]].id
  transit_gateway_route_table_id = each.value

  #need this!
  depends_on = [aws_ec2_transit_gateway_vpc_attachment.this]
}
