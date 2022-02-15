#https://www.terraform.io/docs/configuration/locals
locals {
  ######

  enable = var.enable ? 1 : 0

  prefix = join(module.const.delimiter, compact([
    module.const.prefix,
    var.env,
    var.name,
  ]))

  # tags = var.enable ? merge({
  #   Environment = var.env != "" ? var.env : null
  #   Terraform   = "true"
  # }, var.tags) : {}
  tags = var.tags
}
