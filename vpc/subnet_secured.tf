#https://www.terraform.io/docs/providers/aws/r/subnet.html
resource "aws_subnet" "secured" {
  ###############################
  for_each = local.secured_subnets

  vpc_id = aws_vpc.this[0].id

  cidr_block = lookup(
    var.subnets.secured, "cidr_blocks", null
  ) != null ? element(var.subnets.secured.cidr_blocks, each.value) : cidrsubnet(var.vpc.cidr_block, local.plus_bits, each.value + length(local.public_subnets) + length(local.lb_subnets) + length(local.k8s_subnets) + length(local.misc_subnets))

  availability_zone    = length(local.availability_zones) > 0 ? element(local.availability_zones, each.value) : null
  availability_zone_id = length(local.availability_zone_ids) > 0 ? element(local.availability_zone_ids, each.value) : null

  map_public_ip_on_launch = lookup(
    var.subnets.secured, "map_public_ip_on_launch", null
    ) != null ? var.subnets.secured.map_public_ip_on_launch : lookup(
    var.subnets, "map_public_ip_on_launch", null
  ) != null ? var.subnets.map_public_ip_on_launch : null

  # ipv6
  assign_ipv6_address_on_creation = lookup(
    var.subnets.secured, "assign_ipv6_address_on_creation", null
    ) != null ? var.subnets.secured.assign_ipv6_address_on_creation : lookup(
    var.subnets, "assign_ipv6_address_on_creation", null
  ) != null ? var.subnets.assign_ipv6_address_on_creation : null

  ipv6_cidr_block = lookup(
    var.subnets.secured, "ipv6_cidr_block", null
  ) != null ? element(var.subnets.secured.ipv6_cidr_block, each.value) : null

  # customer_owned_ip
  map_customer_owned_ip_on_launch = lookup(
    var.subnets.secured, "map_customer_owned_ip_on_launch", null
    ) != null ? var.subnets.secured.map_customer_owned_ip_on_launch : lookup(
    var.subnets, "map_customer_owned_ip_on_launch", null
  ) != null ? var.subnets.map_customer_owned_ip_on_launch : null

  customer_owned_ipv4_pool = lookup(
    var.subnets.secured, "customer_owned_ipv4_pool", null
  ) != null ? element(var.subnets.secured.customer_owned_ipv4_pool, each.value) : null

  outpost_arn = lookup(
    var.subnets.secured, "outpost_arn", null
    ) != null ? var.subnets.secured.outpost_arn : lookup(
    var.subnets, "outpost_arn", null
  ) != null ? var.subnets.outpost_arn : null

  tags = merge(local.tags, {
    Name = join(module.const.delimiter, [lookup(
      var.subnets.secured, "name_prefix", null
      ) != null ? var.subnets.secured.name_prefix : lookup(
      var.subnets, "name_prefix", null
      ) != null ? var.subnets.name_prefix : "${local.prefix}${module.const.delimiter}${var.secured_label}",
      each.key,
      module.const.subnet_suffix,
    ])
  })

  dynamic "timeouts" {
    for_each = lookup(var.subnets, "timeouts", null) == null ? [] : [var.subnets.timeouts]
    content {
      create = lookup(timeouts.value, "create", null)
      delete = lookup(timeouts.value, "delete", null)
    }
  }
}
