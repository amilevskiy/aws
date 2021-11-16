################
module "const" {
  ##############
  source = "github.com/amilevskiy/const?ref=v0.1.11"
}

#https://www.terraform.io/docs/configuration/locals.html
locals {
  ######
  tags = var.tags
}
