#https://www.terraform.io/docs/providers/aws/r/subnet
resource "aws_subnet" "this" {
  ############################
  for_each = local.subnets

  vpc_id = aws_vpc.this[0].id

  cidr_block = each.value.cidr_block

  availability_zone = length(local.availability_zones) > 0 ? element(
    local.availability_zones, each.value.zone_index
  ) : null

  availability_zone_id = length(local.availability_zone_ids) > 0 ? element(
    local.availability_zone_ids, each.value.zone_index
  ) : null

  map_public_ip_on_launch = var.subnets[each.value.subnet].map_public_ip_on_launch != null ? (
    var.subnets[each.value.subnet].map_public_ip_on_launch
    ) : var.subnets.map_public_ip_on_launch != null ? (
    var.subnets.map_public_ip_on_launch
  ) : each.value.map_public_ip_on_launch_default

  # ipv6
  assign_ipv6_address_on_creation = var.subnets[each.value.subnet].assign_ipv6_address_on_creation != null ? (
    var.subnets[each.value.subnet].assign_ipv6_address_on_creation
    ) : var.subnets.assign_ipv6_address_on_creation != null ? (
    var.subnets.assign_ipv6_address_on_creation
  ) : null

  ipv6_cidr_block = var.subnets[each.value.subnet].ipv6_cidr_blocks != null ? element(
    var.subnets[each.value.subnet].ipv6_cidr_blocks, each.value.zone_index
  ) : null

  # customer_owned_ip
  map_customer_owned_ip_on_launch = var.subnets[each.value.subnet].map_customer_owned_ip_on_launch != null ? (
    var.subnets[each.value.subnet].map_customer_owned_ip_on_launch
    ) : var.subnets.map_customer_owned_ip_on_launch != null ? (
    var.subnets.map_customer_owned_ip_on_launch
  ) : null

  customer_owned_ipv4_pool = var.subnets[each.value.subnet].customer_owned_ipv4_pool != null ? element(
    var.subnets[each.value.subnet].customer_owned_ipv4_pool, each.value
  ) : null

  outpost_arn = var.subnets[each.value.subnet].outpost_arn != null ? (
    var.subnets[each.value.subnet].outpost_arn
  ) : var.subnets.outpost_arn != null ? var.subnets.outpost_arn : null

  tags = merge(local.tags, var.subnets[each.value.subnet].tags != null
    ? var.subnets[each.value.subnet].tags : {}, {
      Name = join(module.const.delimiter, [
        coalesce(
          var.subnets[each.value.subnet].name_prefix,
          var.subnets.name_prefix,
          join(module.const.delimiter, [
            local.prefix,
            var.label[each.value.subnet]
          ])
        ),
        substr(each.key, -1, 1),
        module.const.subnet_suffix,
  ]) })

  dynamic "timeouts" {
    for_each = var.subnets.timeouts != null ? [var.subnets.timeouts] : []
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
    }
  }
}
