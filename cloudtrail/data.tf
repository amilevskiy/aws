#https://www.terraform.io/docs/providers/aws/d/caller_identity.html
data "aws_caller_identity" "this" {
  #################################
  provider = aws.main

  count = var.account_id == "" ? local.enable : 0
}

#https://www.terraform.io/docs/providers/aws/d/region.html
data "aws_region" "main" {
  ########################
  provider = aws.main

  count = local.enable
}

#https://www.terraform.io/docs/providers/aws/d/region.html
data "aws_region" "replica" {
  ###########################
  provider = aws.replica

  count = local.enable_replica
}


#https://www.terraform.io/docs/configuration/locals.html
locals {
  ######

  enable = var.enable ? 1 : 0

  enable_replica = local.enable

  account_id = var.account_id != "" ? var.account_id : join("", data.aws_caller_identity.this.*.account_id)

  region_main    = join("", data.aws_region.main.*.name)
  region_replica = join("", data.aws_region.replica.*.name)

  # name = coalesce(var.name, join(module.const.delimiter, concat(
  #   [module.const.prefix],
  #   [for k, v in module.const.regions : v.mn_code if v.name == local.region],
  #   compact([module.const.mn_code, var.default_s3_bucket_suffix])
  # )))

  # s3 = { for k, v in keys(var.name_suffix) : k => {
  #   name = join(module.const.delimiter, [coalesce(var.name, join(module.const.delimiter, concat(
  #     [module.const.prefix],
  #     [for kk, vv in module.const.regions : vv.mn_code if vv.name == join("",
  #       can(regex("^main", k)) ? data.aws_region.main.*.name : data.aws_region.replica.*.name)
  #     ],
  #     compact([module.const.mn_code, var.default_s3_bucket_suffix])
  #   ))), v])
  #   acl = can(regex("-log$", k)) ? "log-delivery-write" : module.const.s3_canned_acl_private
  # } }

  tags = var.tags
}
