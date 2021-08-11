#https://www.terraform.io/docs/providers/aws/d/ec2_transit_gateway.html
data "aws_ec2_transit_gateway" "leader" {
  #######################################
  provider = aws.leader

  count = var.enable && (var.leader_resource_arn == null || var.leader_resource_arn == "") ? 1 : 0

  id = var.leader_tgw_id
}

#https://www.terraform.io/docs/providers/aws/d/caller_identity.html
data "aws_caller_identity" "follower" {
  #####################################
  provider = aws.follower

  count = var.enable && (var.follower_principal == null || var.follower_principal == "") ? 1 : 0
}


#https://www.terraform.io/docs/configuration/locals.html
locals {
  ######

  enable = var.enable ? 1 : 0

  prefix = join(module.const.delimiter, compact([
    module.const.prefix, var.env, var.name,
  ]))

  # tags = var.enable ? merge({
  #   Environment = var.env != "" ? var.env : null
  #   Terraform   = "true"
  # }, var.tags) : {}
  tags = var.tags

  # ["tgw-attach-06773499e1535c4e9:100.64.0.0/10", "tgw-attach-06773499e1535c4e9:10.192.0.0/10"]
  routes = toset(var.enable && var.routes != null && var.transit_gateway_route_table_id != "" ? flatten([
    for k, v in var.routes : [for list in setproduct([k], v) : join(":", list)] if can(regex("^tgw-attach-", k))
  ]) : [])
}
