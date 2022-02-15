variable "key_pair" {
  type = object({
    name        = optional(string)
    name_prefix = optional(string)

    public_key = string
  })
  default = null
}

locals {
  # enable_key_pair = var.enable ? var.key_pair != null ? 1 : var.launch_template != null ? var.launch_template.key_name == null ? 1 : 0 : 0 : 0
  enable_key_pair = var.enable && var.key_pair != null ? 1 : 0

  key_pair_name = local.enable_key_pair > 0 ? (
    var.key_pair.name != null
    ) ? var.key_pair.name : (
    var.key_pair.name_prefix == null
  ) ? "${local.prefix}${module.const.delimiter}${module.const.key_pair_suffix}" : null : null
}

#https://www.terraform.io/docs/providers/aws/r/key_pair
resource "aws_key_pair" "this" {
  ##############################
  count = local.enable_key_pair

  key_name        = local.key_pair_name
  key_name_prefix = local.key_pair_name == null ? var.key_pair.name_prefix : null

  public_key = var.key_pair.public_key

  tags = {
    Name = local.key_pair_name
  }
}
