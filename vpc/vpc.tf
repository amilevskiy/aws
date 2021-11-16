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
    condition = var.vpc != null ? (
      var.vpc.instance_tenancy != null ? can(regex(
        "^(?i)(default|dedicated|host)$",
        var.vpc.instance_tenancy
    )) : true) : true

    error_message = "The only possible values are \"default\", \"dedicated\" and \"host\"."
  }

  default = null
}

locals {
  enable_vpc = var.enable && var.vpc != null ? 1 : 0

  #!! doesn't work: try(var.vpc.name, "${local.prefix}${module.const.vpc_suffix}")
  vpc_name = var.vpc != null ? coalesce(
    var.vpc.name,
    join(module.const.delimiter, [
      local.prefix,
      module.const.vpc_suffix,
  ])) : null
}

#https://www.terraform.io/docs/providers/aws/r/vpc.html
resource "aws_vpc" "this" {
  #########################
  count = local.enable_vpc

  cidr_block                       = var.vpc.cidr_block
  instance_tenancy                 = var.vpc.instance_tenancy
  enable_dns_support               = var.vpc.enable_dns_support
  enable_dns_hostnames             = var.vpc.enable_dns_hostnames
  enable_classiclink               = var.vpc.enable_classiclink
  enable_classiclink_dns_support   = var.vpc.enable_classiclink_dns_support
  assign_generated_ipv6_cidr_block = var.vpc.assign_generated_ipv6_cidr_block

  tags = merge(local.tags, {
    Name = local.vpc_name
  })
}
