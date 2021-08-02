variable "transit_gateway" {
  type = object({
    name = optional(string)

    amazon_side_asn = optional(number)
    description     = optional(string)

    enable_auto_accept_shared_attachments  = optional(bool)
    enable_default_route_table_association = optional(bool)
    enable_default_route_table_propagation = optional(bool)
    enable_dns_support                     = optional(bool)
    enable_vpn_ecmp_support                = optional(bool)
  })

  default = null
}

locals {
  transit_gateway_name = var.transit_gateway != null ? (var.transit_gateway.name != null
    ? var.transit_gateway.name
    : "${local.prefix}${module.const.delimiter}${module.const.tgw_suffix}"
  ) : null
}

#https://www.terraform.io/docs/providers/aws/r/ec2_transit_gateway.html
resource "aws_ec2_transit_gateway" "this" {
  #########################################
  count = local.enable

  amazon_side_asn = var.transit_gateway.amazon_side_asn
  description     = var.transit_gateway.description != null ? var.transit_gateway.description : local.transit_gateway_name

  auto_accept_shared_attachments = var.transit_gateway.enable_auto_accept_shared_attachments != null ? (
    var.bool2string[var.transit_gateway.enable_auto_accept_shared_attachments]
  ) : null

  default_route_table_association = var.transit_gateway.enable_default_route_table_association != null ? (
    var.bool2string[var.transit_gateway.enable_default_route_table_association]
  ) : null

  default_route_table_propagation = var.transit_gateway.enable_default_route_table_propagation != null ? (
    var.bool2string[var.transit_gateway.enable_default_route_table_propagation]
  ) : null

  dns_support = var.transit_gateway.enable_dns_support != null ? (
    var.bool2string[var.transit_gateway.enable_dns_support]
  ) : null

  vpn_ecmp_support = var.transit_gateway.enable_vpn_ecmp_support != null ? (
    var.bool2string[var.transit_gateway.enable_vpn_ecmp_support]
  ) : null

  tags = merge(local.tags, {
    Name = local.transit_gateway_name
  })

  lifecycle {
    create_before_destroy = true
  }
}