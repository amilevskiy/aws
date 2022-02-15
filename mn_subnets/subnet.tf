#https://www.terraform.io/docs/providers/aws/r/subnet
resource "aws_subnet" "this" {
  ############################
  for_each = local.subnet_keys

  vpc_id = var.vpc_id

  cidr_block = var.subnets[each.key].cidr_block

  availability_zone = try(var.subnets[each.key].availability_zone, var.availability_zone)
  availability_zone_id = (can(try(var.subnets[each.key].availability_zone, var.availability_zone))
    ? null
    : try(var.subnets[each.key].availability_zone_id, var.availability_zone_id)
  )

  map_public_ip_on_launch = try(
    var.subnets[each.key].map_public_ip_on_launch,
    var.map_public_ip_on_launch
  )

  tags = merge(local.tags, {
    Name = join(module.const.underscore, compact([
      local.tf_stack,
      "subnet",
      each.key
    ]))
  })
}
