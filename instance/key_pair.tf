locals {
  enable_key_pair = var.enable && var.instance != null ? (
    var.instance.public_key != null
  ) ? var.instance.public_key != "" ? 1 : 0 : 0 : 0
}

#https://www.terraform.io/docs/providers/aws/r/key_pair
resource "aws_key_pair" "this" {
  ##############################
  count = local.enable_key_pair

  key_name_prefix = "${local.instance_name}${module.const.delimiter}"
  public_key      = var.instance.public_key

  tags = {
    Name = "${local.instance_name}${module.const.delimiter}${module.const.key_pair_suffix}"
  }
}
