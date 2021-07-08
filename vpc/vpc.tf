variable "vpc" {
  type = object({
    name = optional(string)

    cidr_block                       = string
    instance_tenancy                 = optional(string) # default, dedicated, host
    enable_dns_support               = optional(bool)   # Defaults true
    enable_dns_hostnames             = optional(bool)   # Defaults false
    enable_classiclink               = optional(bool)   # Defaults false
    enable_classiclink_dns_support   = optional(bool)
    assign_generated_ipv6_cidr_block = optional(bool) # Defaults false
  })

  validation {
    condition = var.vpc != null ? lookup(
      var.vpc, "instance_tenancy", null
      ) != null ? can(regex(
        "^(?i)(default|dedicated|host)$",
        var.vpc.instance_tenancy
    )) : true : true

    error_message = "The only possible values are \"default\", \"dedicated\" and \"host\"."
  }

  default = null
}

locals {
  enable_vpc = var.enable && var.vpc != null ? 1 : 0

  #!! doesn't work: try(var.vpc.name, "${local.prefix}${module.const.vpc_suffix}")
  vpc_name = var.vpc != null ? lookup(
    var.vpc, "name", null
  ) != null ? var.vpc.name : "${local.prefix}${module.const.delimiter}${module.const.vpc_suffix}" : null
}

#https://www.terraform.io/docs/providers/aws/r/vpc.html
resource "aws_vpc" "this" {
  #########################
  count = local.enable_vpc

  cidr_block                       = var.vpc.cidr_block
  instance_tenancy                 = lookup(var.vpc, "instance_tenancy", null)
  enable_dns_support               = lookup(var.vpc, "enable_dns_support", null)
  enable_dns_hostnames             = lookup(var.vpc, "enable_dns_hostnames", null)
  enable_classiclink               = lookup(var.vpc, "enable_classiclink", null)
  enable_classiclink_dns_support   = lookup(var.vpc, "enable_classiclink_dns_support", null)
  assign_generated_ipv6_cidr_block = lookup(var.vpc, "assign_generated_ipv6_cidr_block", null)

  tags = merge(var.tags, {
    Name = local.vpc_name
  })
}
