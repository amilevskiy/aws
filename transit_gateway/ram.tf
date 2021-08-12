variable "resource_share" {
  type = object({
    name = optional(string)

    allow_external_principals = optional(bool)
    follower_principals       = optional(map(string))

    depends_on_list = list(string)
  })

  default = null
}

locals {
  enable_resource_share = var.enable && var.resource_share != null ? 1 : 0

  resource_share_name = (local.enable_resource_share > 0
    ? var.resource_share.name != null
    ? var.resource_share.name
    : "${local.transit_gateway_name}${module.const.delimiter}${module.const.ram_suffix}"
  : null)

  follower_principals = (local.enable_resource_share > 0
    ? var.resource_share.follower_principals != null
    ? var.resource_share.follower_principals
  : {} : {})

  depends_on_list = (local.enable_resource_share > 0
    ? var.resource_share.depends_on_list != null
    ? var.resource_share.depends_on_list
  : [] : [])
}

#https://www.terraform.io/docs/providers/aws/r/ram_resource_share.html
resource "aws_ram_resource_share" "this" {
  ########################################
  count = local.enable_resource_share

  name = local.resource_share_name

  allow_external_principals = local.enable_resource_share > 0 ? (
    var.resource_share.allow_external_principals != null
    ) ? var.resource_share.allow_external_principals : length(
    local.follower_principals
  ) > 0 ? true : null : null

  tags = merge(local.tags, {
    Name = local.resource_share_name
  })
}

# Share the transit gateway...
#https://www.terraform.io/docs/providers/aws/r/ram_resource_association.html
resource "aws_ram_resource_association" "this" {
  ##############################################
  count = local.enable_resource_share

  #arn:aws:ec2:us-east-1:318068638372:transit-gateway/tgw-06773499e1535c4e9
  resource_arn       = aws_ec2_transit_gateway.this[0].arn
  resource_share_arn = aws_ram_resource_share.this[0].arn
}


#https://www.terraform.io/docs/providers/aws/r/ram_principal_association.html
resource "aws_ram_principal_association" "this" {
  ###############################################
  for_each = local.follower_principals

  principal          = each.key
  resource_share_arn = aws_ram_resource_share.this[0].arn
}

#https://www.terraform.io/docs/providers/template/d/file.html
data "template_file" "this" {
  ###########################
  for_each = local.follower_principals

  vars = {
    resource_id = "${aws_ec2_transit_gateway.this[0].id}_${each.key}"
    provider    = each.value
    share_arn   = aws_ram_principal_association.this[each.key].resource_share_arn
    count_condition = (length(local.depends_on_list) > 0
      ? join(" && ", formatlist("%s.enable", local.depends_on_list))
      : "var.enable"
    )
  }

  #https://www.terraform.io/docs/providers/aws/r/ram_resource_share_accepter.html
  template = <<-TEMPLATE
resource "aws_ram_resource_share_accepter" "$${resource_id}" {
  provider = $${provider}

  count = $${count_condition} ? 1 : 0

  share_arn = "$${share_arn}"

${length(local.depends_on_list) > 0 ? format("  depends_on = [%s]", join(", ", local.depends_on_list)) : ""}
}
	TEMPLATE
}
