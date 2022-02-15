################
module "const" {
  ##############
  source = "github.com/amilevskiy/const?ref=v0.1.11"
}

#https://www.terraform.io/docs/providers/aws/r/ram_resource_share
resource "aws_ram_resource_share" "leader" {
  ##########################################
  provider = aws.leader

  count = local.enable

  name = coalesce(
    var.leader_resource_share_name,
    join(module.const.delimiter, [
      local.prefix,
      module.const.ram_suffix,
  ]))

  allow_external_principals = var.leader_allow_external_principals

  tags = merge(local.tags, {
    Name = coalesce(
      var.leader_resource_share_tag_name,
      join(module.const.delimiter, [
        local.prefix,
        module.const.ram_suffix,
    ]))
  })
}

# Share the transit gateway...
#https://www.terraform.io/docs/providers/aws/r/ram_resource_association
resource "aws_ram_resource_association" "leader" {
  ################################################
  provider = aws.leader

  count = local.enable

  #arn:aws:ec2:us-east-1:318068638372:transit-gateway/tgw-06773499e1535c4e9
  resource_arn       = try(data.aws_ec2_transit_gateway.leader[0].arn, var.leader_resource_arn)
  resource_share_arn = aws_ram_resource_share.leader[0].arn
}

#https://www.terraform.io/docs/providers/aws/r/ram_principal_association
resource "aws_ram_principal_association" "leader" {
  #################################################
  provider = aws.leader

  count = local.enable

  principal          = try(data.aws_caller_identity.follower[0].account_id, var.follower_principal)
  resource_share_arn = aws_ram_resource_share.leader[0].arn
}

#https://www.terraform.io/docs/providers/aws/r/ec2_transit_gateway_route
resource "aws_ec2_transit_gateway_route" "this" {
  ################################################
  provider = aws.leader

  for_each = local.routes

  destination_cidr_block         = split(":", each.key)[1]
  transit_gateway_attachment_id  = split(":", each.key)[0]
  transit_gateway_route_table_id = var.transit_gateway_route_table_id
}


#https://www.terraform.io/docs/providers/aws/r/ram_resource_share_accepter
resource "aws_ram_resource_share_accepter" "follower" {
  #####################################################
  provider = aws.follower

  count = local.enable

  share_arn = aws_ram_principal_association.leader[0].resource_share_arn

  depends_on = [aws_ram_resource_association.leader]
}

