#https://www.terraform.io/docs/configuration/locals.html
locals {
  ######

  enable = var.enable ? 1 : 0

  # prefix = "${join(module.const.delimiter, compact([
  #   module.const.prefix,
  #   var.env,
  #   var.name,
  # ]))}${module.const.delimiter}"

  prefix = join(module.const.delimiter, compact([
    module.const.prefix,
    var.env,
    var.name,
  ]))

  tags = var.enable ? merge({
    Environment = var.env != "" ? var.env : null
    Terraform   = "true"
  }, var.tags) : {}

  # dhcp_domain_name = lower(replace(
  #   var.dhcp_domain_name, module.const.regexp_tail_dots, ""
  # ))
}
