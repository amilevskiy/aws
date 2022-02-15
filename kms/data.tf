#https://www.terraform.io/docs/configuration/locals
locals {
  ######

  enable = var.enable ? 1 : 0

  tags = var.tags
}
