#https://www.terraform.io/docs/configuration/locals.html
locals {
  ######

  enable = var.enable ? 1 : 0

  #20-ngw -> ngw
  root_env = [for i in split(module.const.delimiter, lower(var.env)) : i if length(regexall("^[0-9]+$", i)) == 0][0]

  #AWS-CLEAN-
  prefix = "${module.const.prefix}${module.const.delimiter}${local.root_env}${module.const.delimiter}"

  awscli_args = join(" ", compact([
    var.aws_region == "" ? "" : "--region",
    var.aws_region,
    var.aws_profile == "" ? "" : "--profile",
    var.aws_profile,
  ]))

  tags = {
    Environment = var.env
    Terraform   = "true"
  }
}
