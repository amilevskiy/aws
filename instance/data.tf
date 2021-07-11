#https://www.terraform.io/docs/configuration/locals.html
locals {
  ######

  enable = var.enable ? 1 : 0

  prefix = join(module.const.delimiter, compact([
    module.const.prefix,
    var.env,
    var.name,
  ]))

  tags = var.tags
}
