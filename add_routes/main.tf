#https://www.terraform.io/docs/providers/aws/d/route_tables
##################################
data "aws_route_tables" "theese" {
  ################################
  count = var.enable ? length(var.vpc_ids) : 0

  vpc_id = var.vpc_ids[count.index]
}

#https://www.terraform.io/docs/providers/aws/r/route
resource "aws_route" "this" {
  ###########################
  for_each = toset(var.enable ? [
    for v in setproduct(
      flatten(data.aws_route_tables.theese.*.ids),
      var.cidr_blocks
    ) : join(":", v)
  ] : [])

  route_table_id         = split(":", each.key)[0]
  destination_cidr_block = split(":", each.key)[1]
  transit_gateway_id     = var.transit_gateway_id
}
