variable "dhcp_options" {
  type = object({
    name = optional(string)

    domain_name          = optional(string)
    domain_name_servers  = optional(list(string))
    ntp_servers          = optional(list(string))
    netbios_name_servers = optional(list(string))
    netbios_node_type    = optional(number)
  })

  validation {
    condition = var.dhcp_options != null ? (
      var.dhcp_options.netbios_node_type != null ?
      var.dhcp_options.netbios_node_type == 0 ||
      var.dhcp_options.netbios_node_type == 1 ||
      var.dhcp_options.netbios_node_type == 2 ||
      var.dhcp_options.netbios_node_type == 4 ||
      var.dhcp_options.netbios_node_type == 8
    : true) : true

    error_message = "The only possible values are \"0\", \"1\", \"2\", \"4\" and \"8\"."
  }

  default = null
}


locals {
  enable_dhcp_options = var.enable && var.dhcp_options != null ? 1 : 0

  dhcp_options_name = var.dhcp_options != null ? (
    var.dhcp_options.name != null
    ? var.dhcp_options.name
    : "${local.prefix}${module.const.delimiter}${module.const.dhcp_options_suffix}"
  ) : null
}


#https://www.terraform.io/docs/providers/aws/r/vpc_dhcp_options
resource "aws_vpc_dhcp_options" "this" {
  ######################################
  count = local.enable_dhcp_options

  domain_name = var.dhcp_options.domain_name

  #null -> ["AmazonProvidedDNS"]
  #[] -> null
  #["10.1.2.3", "10.2.3.4"] -> ["10.1.2.3", "10.2.3.4"]
  domain_name_servers = var.dhcp_options.domain_name_servers != null ? length(
    var.dhcp_options.domain_name
  ) > 0 ? var.dhcp_options.domain_name_servers : null : ["AmazonProvidedDNS"]

  #null -> ["169.254.169.123"]
  #[] -> null
  #["10.1.2.3", "10.2.3.4"] -> ["10.1.2.3", "10.2.3.4"]
  ntp_servers = var.dhcp_options.ntp_servers != null ? length(
    var.dhcp_options.ntp_servers
  ) > 0 ? var.dhcp_options.ntp_servers : null : ["169.254.169.123"]

  #null -> ["127.0.0.1"]
  #[] -> null
  #["10.1.2.3", "10.2.3.4"] -> ["10.1.2.3", "10.2.3.4"]
  netbios_name_servers = var.dhcp_options.netbios_name_servers != null ? length(
    var.dhcp_options.netbios_name_servers
  ) > 0 ? var.dhcp_options.netbios_name_servers : null : ["127.0.0.1"]

  #null -> 2
  #0 -> null
  #1,2,4,8 -> 1,2,4,8
  netbios_node_type = var.dhcp_options.netbios_node_type != null ? (
    var.dhcp_options.netbios_node_type > 0 ? var.dhcp_options.netbios_node_type : null
  ) : 2

  tags = merge(local.tags, {
    Name = local.dhcp_options_name
  })
}

#https://www.terraform.io/docs/providers/aws/r/vpc_dhcp_options_association
resource "aws_vpc_dhcp_options_association" "this" {
  ##################################################
  count = local.enable_dhcp_options

  vpc_id          = var.vpc_id
  dhcp_options_id = aws_vpc_dhcp_options.this[0].id
}

