variable "vpc" {
  type = object({
    id                = string
    cidr_block        = string
    subnet_cidr_block = optional(set(string))
  })

  default = null
}

locals {
  enable_vpc = var.enable && var.vpc != null ? 1 : 0
}
