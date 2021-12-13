#https://www.terraform.io/docs/configuration/locals.html
locals {
  ######

  enable = var.enable ? 1 : 0

  tags = var.tags
}
