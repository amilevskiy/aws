variable "placement_group" {
  type = object({
    name = optional(string)

    strategy = optional(string) #"cluster", "partition" or "spread".
  })

  validation {
    condition = var.placement_group != null ? (
      var.placement_group.strategy != null ? can(regex(
        "^(cluster|partition|spread)$",
        var.placement_group.strategy
    )) : true) : true

    error_message = "The only possible values are \"cluster\", \"partition\" and \"spread\"."
  }

  default = null
}

locals {
  placement_group = var.enable && var.placement_group != null ? 1 : 0

  placement_group_name = local.placement_group > 0 ? var.placement_group.name != null ? (
    var.placement_group.name
  ) : "${local.prefix}${module.const.delimiter}${local.placement_group_strategy}${module.const.delimiter}${module.const.placement_group_suffix}" : null

  placement_group_strategy = local.placement_group > 0 ? var.placement_group.strategy != null ? (
    var.placement_group.strategy
  ) : "spread" : null
}

#https://www.terraform.io/docs/providers/aws/r/placement_group
resource "aws_placement_group" "this" {
  #####################################
  count = local.placement_group

  name     = local.placement_group_name
  strategy = local.placement_group_strategy

  tags = {
    "Name" = local.placement_group_name
  }
}
