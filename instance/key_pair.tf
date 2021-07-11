locals {
  enable_key_pair = var.enable && var.instance != null && var.public_key != "" ? lookup(
    var.instance, "key_name", null
  ) != null ? var.instance.key_name != "" ? 0 : 1 : 1 : 0
}

#https://www.terraform.io/docs/providers/aws/r/key_pair.html
resource "aws_key_pair" "this" {
  ##############################
  count = local.enable_key_pair

  key_name_prefix = "${local.instance_name}${module.const.delimiter}"
  public_key      = var.public_key

  tags = {
    Name = "${local.instance_name}${module.const.delimiter}${module.const.key_pair_suffix}"
  }
}
