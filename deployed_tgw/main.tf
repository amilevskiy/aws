################
module "const" {
  ##############
  source = "github.com/amilevskiy/const?ref=v0.1.4"
}

#https://www.terraform.io/docs/providers/aws/r/ram_resource_share.html
resource "aws_ram_resource_share" "leader" {
  ##########################################
  provider = aws.leader

  count = local.enable

  name = coalesce(
    var.leader_resource_share_name,
    "${local.prefix}${module.const.delimiter}${module.const.ram_suffix}"
  )

  allow_external_principals = var.leader_allow_external_principals

  tags = merge(local.tags, {
    Name = coalesce(
      var.leader_resource_share_tag_name,
      "${local.prefix}${module.const.delimiter}${module.const.ram_suffix}"
    )
  })
}

# Share the transit gateway...
#https://www.terraform.io/docs/providers/aws/r/ram_resource_association.html
resource "aws_ram_resource_association" "leader" {
  ################################################
  provider = aws.leader

  count = local.enable

  #arn:aws:ec2:us-east-1:318068638372:transit-gateway/tgw-06773499e1535c4e9
  resource_arn       = coalescelist(data.aws_ec2_transit_gateway.leader.*.arn, [var.leader_resource_arn])[0]
  resource_share_arn = aws_ram_resource_share.leader[0].arn
}


#https://www.terraform.io/docs/providers/aws/r/ram_principal_association.html
resource "aws_ram_principal_association" "leader" {
  #################################################
  provider = aws.leader

  count = local.enable

  principal          = coalescelist(data.aws_caller_identity.follower.*.account_id, [var.follower_principal])[0]
  resource_share_arn = aws_ram_resource_share.leader[0].arn
}


#https://www.terraform.io/docs/providers/aws/r/ram_resource_share_accepter.html
resource "aws_ram_resource_share_accepter" "follower" {
  #####################################################
  provider = aws.follower

  count = local.enable

  share_arn = aws_ram_principal_association.leader[0].resource_share_arn
}
