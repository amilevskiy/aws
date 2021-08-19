#https://www.terraform.io/docs/providers/aws/r/subnet.html
resource "aws_subnet" "this" {
  ############################
  for_each = local.subnets

  vpc_id = var.vpc.id

  cidr_block = each.value.cidr_block

  availability_zone    = each.value.availability_zone
  availability_zone_id = each.value.availability_zone_id

  map_public_ip_on_launch = each.value.map_public_ip_on_launch

  tags = merge(local.tags, {
    Name = join(module.const.underscore, compact([
      local.tf_stack,
      "subnet",
      each.key
    ]))
  })
}
