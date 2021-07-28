variable "transit_gateway" {
  type = object({
    name = optional(string)

    amazon_side_asn                 = optional(number)
    auto_accept_shared_attachments  = optional(string) # disable, enable. Default value: disable
    default_route_table_association = optional(string) # disable, enable. Default value: enable
    default_route_table_propagation = optional(string) # disable, enable. Default value: enable
    description                     = optional(string)
    dns_support                     = optional(string) # disable, enable. Default value: enable
    vpn_ecmp_support                = optional(string) # disable, enable. Default value: enable
  })

  validation {
    condition = var.transit_gateway != null ? (
      var.transit_gateway.auto_accept_shared_attachments != null ? can(regex(
        "^(?i)(disable|enable)$",
        var.transit_gateway.auto_accept_shared_attachments
    )) : true) : true

    error_message = "The only possible values are \"disable\" and \"enable\"."
  }

  validation {
    condition = var.transit_gateway != null ? (
      var.transit_gateway.default_route_table_association != null ? can(regex(
        "^(?i)(disable|enable)$",
        var.transit_gateway.default_route_table_association
    )) : true) : true

    error_message = "The only possible values are \"disable\" and \"enable\"."
  }

  validation {
    condition = var.transit_gateway != null ? (
      var.transit_gateway.default_route_table_propagation != null ? can(regex(
        "^(?i)(disable|enable)$",
        var.transit_gateway.default_route_table_propagation
    )) : true) : true

    error_message = "The only possible values are \"disable\" and \"enable\"."
  }

  validation {
    condition = var.transit_gateway != null ? (
      var.transit_gateway.dns_support != null ? can(regex(
        "^(?i)(disable|enable)$",
        var.transit_gateway.dns_support
    )) : true) : true

    error_message = "The only possible values are \"disable\" and \"enable\"."
  }

  validation {
    condition = var.transit_gateway != null ? (
      var.transit_gateway.vpn_ecmp_support != null ? can(regex(
        "^(?i)(disable|enable)$",
        var.transit_gateway.vpn_ecmp_support
    )) : true) : true

    error_message = "The only possible values are \"disable\" and \"enable\"."
  }

  default = null
}

locals {
  # enable_vpc = var.enable && var.vpc != null ? 1 : 0

  transit_gateway_name = var.transit_gateway != null ? (var.transit_gateway.name != null
    ? var.transit_gateway.name
    : "${local.prefix}${module.const.delimiter}${module.const.tgw_suffix}"
  ) : null
}


#https://www.terraform.io/docs/providers/aws/r/ec2_transit_gateway.html
resource "aws_ec2_transit_gateway" "this" {
  #########################################
  count = local.enable

  amazon_side_asn                 = var.transit_gateway.amazon_side_asn
  auto_accept_shared_attachments  = var.transit_gateway.auto_accept_shared_attachments
  default_route_table_association = var.transit_gateway.default_route_table_association
  default_route_table_propagation = var.transit_gateway.default_route_table_propagation
  description                     = var.transit_gateway.description != null ? var.transit_gateway.description : local.transit_gateway_name
  dns_support                     = var.transit_gateway.dns_support
  vpn_ecmp_support                = var.transit_gateway.vpn_ecmp_support

  tags = merge(local.tags, {
    Name = local.transit_gateway_name
  })

  lifecycle {
    create_before_destroy = true
  }
}
