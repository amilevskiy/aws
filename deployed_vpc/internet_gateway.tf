variable "internet_gateway" {
  type = object({
    name = optional(string)
  })

  default = null
}

locals {
  enable_internet_gateway = var.enable && var.internet_gateway != null ? 1 : 0

  internet_gateway_name = var.internet_gateway != null ? (
    var.internet_gateway.name != null
    ? var.internet_gateway.name
    : "${local.prefix}${module.const.delimiter}${module.const.igw_suffix}"
  ) : null
}

#https://www.terraform.io/docs/providers/aws/r/internet_gateway.html
resource "aws_internet_gateway" "this" {
  ######################################
  count = local.enable_internet_gateway

  vpc_id = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.tags, {
    Name = local.internet_gateway_name
  })
}
