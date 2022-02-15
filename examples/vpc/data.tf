locals {
  availability_zones = {
    "us-east-1a" = "use1-az2"
    "us-east-1b" = "use1-az4"
    "us-east-1c" = "use1-az6"
    "us-east-1d" = "use1-az1"
    "us-east-1e" = "use1-az3"
    "us-east-1f" = "use1-az5"
  }
}

#https://www.terraform.io/docs/configuration/locals
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
