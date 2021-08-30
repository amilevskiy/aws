#для timeouts нет места :(
variable "subnets" {
  type = map(object({
    availability_zone    = optional(string)
    availability_zone_id = optional(string)

    cidr_block = optional(string)

    map_public_ip_on_launch = optional(bool) # Default: false

    network_acl_inbound_rules  = optional(list(string))
    network_acl_outbound_rules = optional(list(string))
  }))

  default = null
}

locals {
  enable_subnets = var.enable && var.subnets != null ? min(1, length(var.subnets)) : 0

  subnet_keys = toset(local.enable_subnets > 0 ? [for k, v in var.subnets : k if v.cidr_block != null] : [])

  cidr_blocks = [for v in local.subnet_keys : var.subnets[v].cidr_block]


  inbound_sliced = { for k in local.subnet_keys : k => ([
    for v in concat(
      formatlist("allow * %s", setsubtract(local.cidr_blocks, [var.subnets[k].cidr_block])),
      var.subnets[k].network_acl_inbound_rules != null ? var.subnets[k].network_acl_inbound_rules : []
    ) : split(" ", lower(replace(v, "/\\s+/", " ")))
  ]) } # map(list(list(string)))

  inbound_expanded = { for k, v in local.inbound_sliced : k => flatten([
    for vv in v : can(split(",", vv[2])) ? [
      for vvv in split(",", vv[2]) : join(" ", concat(
        slice(vv, 0, 2), [can(regex("\\*|/", vvv)) ? vvv : "${vvv}/32"], try(slice(vv, 3, length(vv)), [])
    ))] : [join(" ", vv)]
  ]) } # map(list(string))

  inbound_normalized = {
    for k, v in local.inbound_expanded : k => {
      for vv in range(length(v))
      : format("%05d", var.network_acl_rule_start + vv * var.network_acl_rule_step) => split(" ", v[vv])
  } } # map(map(list(string)))

  inbound_keys = flatten([
    for k, v in local.inbound_normalized : [
      for vv in setproduct([k], keys(v)) : join(module.const.delimiter, vv)
    ]
  ]) # list(string)

  inbound_network_acls = {
    for v in local.inbound_keys : v => local.inbound_normalized[split(module.const.delimiter, v)[0]][split(module.const.delimiter, v)[1]]
  } # map(list(string))


  # for v in try(var.subnets[k].network_acl_outbound_rules, []) : split(" ", lower(replace(v, "/\\s+/", " ")))
  outbound_sliced = { for k in local.subnet_keys : k => ([
    for v in concat(
      formatlist("allow * %s", setsubtract(local.cidr_blocks, [var.subnets[k].cidr_block])),
      var.subnets[k].network_acl_outbound_rules != null ? var.subnets[k].network_acl_outbound_rules : []
    ) : split(" ", lower(replace(v, "/\\s+/", " ")))
  ]) } # map(list(list(string)))

  outbound_expanded = { for k, v in local.outbound_sliced : k => flatten([
    for vv in v : can(split(",", vv[2])) ? [
      for vvv in split(",", vv[2]) : join(" ", concat(
        slice(vv, 0, 2), [can(regex("\\*|/", vvv)) ? vvv : "${vvv}/32"], try(slice(vv, 3, length(vv)), [])
    ))] : [join(" ", vv)]
  ]) } # map(list(string))

  outbound_normalized = {
    for k, v in local.outbound_expanded : k => {
      for vv in range(length(v))
      : format("%05d", var.network_acl_rule_start + vv * var.network_acl_rule_step) => split(" ", v[vv])
  } } # map(map(list(string)))

  outbound_keys = flatten([
    for k, v in local.outbound_normalized : [
      for vv in setproduct([k], keys(v)) : join(module.const.delimiter, vv)
    ]
  ]) # list(string)

  outbound_network_acls = {
    for v in local.outbound_keys : v => local.outbound_normalized[split(module.const.delimiter, v)[0]][split(module.const.delimiter, v)[1]]
  } # map(list(string))
}
