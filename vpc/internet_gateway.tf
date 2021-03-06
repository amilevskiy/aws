variable "internet_gateway" {
  type = object({
    name = optional(string)
  })

  default = null

  description = "The object which describes \"aws_internet_gateway\" resource"
}

locals {
  enable_internet_gateway = local.enable_vpc > 0 && var.internet_gateway != null ? 1 : 0

  internet_gateway_name = var.internet_gateway != null ? coalesce(
    var.internet_gateway.name,
    join(module.const.delimiter, [
      local.prefix,
      module.const.igw_suffix,
  ])) : null
}

#https://www.terraform.io/docs/providers/aws/r/internet_gateway
resource "aws_internet_gateway" "this" {
  ######################################
  count = local.enable_internet_gateway

  vpc_id = aws_vpc.this[0].id

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.tags, {
    Name = local.internet_gateway_name
  })
}
