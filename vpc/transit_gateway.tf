variable "transit_gateway_vpc_attachment" {
  type = object({
    name = optional(string)

    id                     = string
    appliance_mode_support = optional(string) # Default value: disable.
    dns_support            = optional(string) # Default value: enable.
    ipv6_support           = optional(string) # Default value: disable.

    transit_gateway_default_route_table_association = optional(bool) # Default value: true.
    transit_gateway_default_route_table_propagation = optional(bool) # Default value: true.

    route_cidrs = optional(list(string))
  })

  validation {
    condition = var.transit_gateway_vpc_attachment != null ? (
      var.transit_gateway_vpc_attachment.appliance_mode_support != null ? can(regex(
        "^(?i)(disable|enable)$",
        var.transit_gateway_vpc_attachment.appliance_mode_support
    )) : true) : true

    error_message = "The only possible values are \"disable\" and \"enable\"."
  }

  validation {
    condition = var.transit_gateway_vpc_attachment != null ? (
      var.transit_gateway_vpc_attachment.dns_support != null ? can(regex(
        "^(?i)(disable|enable)$",
        var.transit_gateway_vpc_attachment.dns_support
    )) : true) : true

    error_message = "The only possible values are \"disable\" and \"enable\"."
  }

  validation {
    condition = var.transit_gateway_vpc_attachment != null ? (
      var.transit_gateway_vpc_attachment.ipv6_support != null ? can(regex(
        "^(?i)(disable|enable)$",
        var.transit_gateway_vpc_attachment.ipv6_support
    )) : true) : true

    error_message = "The only possible values are \"disable\" and \"enable\"."
  }

  default = null
}


locals {
  enable_transit_gateway_vpc_attachment = local.enable_subnets && var.transit_gateway_vpc_attachment != null ? 1 : 0

  transit_gateway_vpc_attachment_name = var.transit_gateway_vpc_attachment != null ? (
    var.transit_gateway_vpc_attachment.name != null ? (
      var.transit_gateway_vpc_attachment.name
    ) : "${local.vpc_name}${module.const.delimiter}${module.const.tgw_attachment_suffix}"
  ) : null

  transit_gateway_route_cidrs = local.enable_transit_gateway_vpc_attachment > 0 && var.transit_gateway_vpc_attachment != null ? (
    var.transit_gateway_vpc_attachment.route_cidrs != null ? var.transit_gateway_vpc_attachment.route_cidrs : []
  ) : []
}

#https://www.terraform.io/docs/providers/aws/r/ec2_transit_gateway_vpc_attachment.html
resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  ########################################################
  count = local.enable_transit_gateway_vpc_attachment

  vpc_id             = aws_vpc.this[0].id
  transit_gateway_id = var.transit_gateway_vpc_attachment.id

  subnet_ids = [
    for k, v in aws_subnet.this : v.id if can(regex("^secured-", k))
  ]

  appliance_mode_support                          = var.transit_gateway_vpc_attachment.appliance_mode_support
  dns_support                                     = var.transit_gateway_vpc_attachment.dns_support
  ipv6_support                                    = var.transit_gateway_vpc_attachment.ipv6_support
  transit_gateway_default_route_table_association = var.transit_gateway_vpc_attachment.transit_gateway_default_route_table_association
  transit_gateway_default_route_table_propagation = var.transit_gateway_vpc_attachment.transit_gateway_default_route_table_propagation

  tags = {
    Name = local.transit_gateway_vpc_attachment_name
  }
}
