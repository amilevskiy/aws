# ############################
# data "cidr_network" "test" {
#   ##########################
#   count = local.enable

#   cidr_block          = var.vpc.cidr_block
#   exclude_cidr_blocks = try(var.vpc.subnet_cidr_block, [])
#   prefix_lengths      = local.prefix_lengths
# }

#https://www.terraform.io/docs/providers/external/data_source.html
data "external" "cidr" {
  ######################
  count = min(1, length(local.subnets_keys))

  program = [
    "${path.module}/cidr_block",
  ]

  #The JSON object contains the contents of the query argument and its values will always be strings.
  query = {
    cidr_block          = var.vpc.cidr_block
    exclude_cidr_blocks = try(join(" ", var.vpc.subnet_cidr_block), "")
    prefix_lengths      = join(" ", local.prefix_lengths)
  }
}


#для timeouts нет места :(
variable "subnets" {
  type = map(object({
    hosts = optional(number)

    availability_zone    = optional(string)
    availability_zone_id = optional(string)

    map_public_ip_on_launch = optional(bool) # Default: false

    network_acl_inbound_rules  = optional(list(string))
    network_acl_outbound_rules = optional(list(string))
  }))

  default = null
}

locals {
  enable_subnets = var.enable && var.subnets != null ? min(1, length(var.subnets)) : 0

  subnets_keys = local.enable_subnets > 0 ? keys(var.subnets) : toset([])

  prefix_lengths = [
    for k in local.subnets_keys : max(try(var.max_ipv4_prefix - ceil(log(var.subnets[k].hosts, 2)), 28), 28)
  ]

  cidr_blocks = flatten([for v in data.external.cidr.*.result.cidr_blocks : split(" ", v)])


  subnets = {
    for i in range(length(local.subnets_keys)) : local.subnets_keys[i] => {
      availability_zone       = var.subnets[local.subnets_keys[i]].availability_zone
      availability_zone_id    = var.subnets[local.subnets_keys[i]].availability_zone_id
      cidr_block              = local.cidr_blocks[i]
      map_public_ip_on_launch = var.subnets[local.subnets_keys[i]].map_public_ip_on_launch
    }
  }


  inbound_sliced = { for k in local.subnets_keys : k => ([
    for v in concat(formatlist("allow * %s", local.cidr_blocks), try(var.subnets[k].network_acl_inbound_rules, [])) : split(" ", lower(replace(v, "/\\s+/", " ")))
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
  outbound_sliced = { for k in local.subnets_keys : k => ([
    for v in concat(formatlist("allow * %s", local.cidr_blocks), try(var.subnets[k].network_acl_outbound_rules, [])) : split(" ", lower(replace(v, "/\\s+/", " ")))
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


# #https://registry.terraform.io/providers/skeggse/metadata/latest/docs/resources/value
# resource "metadata_value" "subnet" {
#   ##################################
#   for_each = local.subnets

#   update = true
#   #allow tcp 10.103.9.16/28 1521 1522
#   inputs = {
#     vpc_id                  = var.vpc.id
#     cidr_block              = each.value.cidr_block
#     availability_zone       = each.value.availability_zone
#     map_public_ip_on_launch = each.value.map_public_ip_on_launch
#   }
# }
