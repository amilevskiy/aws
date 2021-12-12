#https://www.terraform.io/docs/providers/aws/d/caller_identity.html
data "aws_caller_identity" "this" {
  #################################
  count = var.account_id == "" ? local.enable : 0
}

#https://www.terraform.io/docs/providers/aws/d/region.html
data "aws_region" "main" {
  ########################
  count = local.enable
}


#https://www.terraform.io/docs/configuration/locals.html
locals {
  ######

  enable = var.enable ? 1 : 0

  account_id = var.account_id != "" ? var.account_id : join("", data.aws_caller_identity.this.*.account_id)

  region       = join("", data.aws_region.main.*.name)
  region_short = replace(local.region, "/^([^-]+)-([^-]).+-([^-]+)$/", "$1$2$3")

  tags = var.tags
}
