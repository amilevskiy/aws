variable "subnets" {
  type = object({
    name_prefix = optional(string)

    availability_zones    = optional(list(string))
    availability_zone_ids = optional(list(string))

    map_public_ip_on_launch         = optional(bool) # Default: false
    assign_ipv6_address_on_creation = optional(bool) # Default: false

    # intentionally omit support of the following due to lack of testing?
    map_customer_owned_ip_on_launch = optional(bool) # Default: false
    outpost_arn                     = optional(string)

    propagating_vgws = optional(list(string))

    public = optional(object({
      name_prefix = optional(string)

      hosts = optional(number)

      cidr_blocks             = optional(list(string))
      map_public_ip_on_launch = optional(bool) # Default: false

      assign_ipv6_address_on_creation = optional(bool)         # Default: false
      ipv6_cidr_blocks                = optional(list(string)) # /64

      map_customer_owned_ip_on_launch = optional(bool) # Default: false
      customer_owned_ipv4_pool        = optional(list(string))
      outpost_arn                     = optional(string)

      propagating_vgws = optional(list(string))

      routes = optional(map(list(string)))
    }))

    lb = optional(object({
      name_prefix = optional(string)

      hosts = optional(number)

      cidr_blocks             = optional(list(string))
      map_public_ip_on_launch = optional(bool) # Default: false

      assign_ipv6_address_on_creation = optional(bool)         # Default: false
      ipv6_cidr_blocks                = optional(list(string)) # /64

      map_customer_owned_ip_on_launch = optional(bool) # Default: false
      customer_owned_ipv4_pool        = optional(list(string))
      outpost_arn                     = optional(string)

      propagating_vgws = optional(list(string))

      routes = optional(map(list(string)))
    }))

    k8s = optional(object({
      name_prefix = optional(string)

      hosts = optional(number)

      cidr_blocks             = optional(list(string))
      map_public_ip_on_launch = optional(bool) # Default: false

      assign_ipv6_address_on_creation = optional(bool)         # Default: false
      ipv6_cidr_blocks                = optional(list(string)) # /64

      map_customer_owned_ip_on_launch = optional(bool) # Default: false
      customer_owned_ipv4_pool        = optional(list(string))
      outpost_arn                     = optional(string)

      propagating_vgws = optional(list(string))

      routes = optional(map(list(string)))
    }))

    misc = optional(object({
      name_prefix = optional(string)

      hosts = optional(number)

      cidr_blocks             = optional(list(string))
      map_public_ip_on_launch = optional(bool) # Default: false

      assign_ipv6_address_on_creation = optional(bool)         # Default: false
      ipv6_cidr_blocks                = optional(list(string)) # /64

      map_customer_owned_ip_on_launch = optional(bool) # Default: false
      customer_owned_ipv4_pool        = optional(list(string))
      outpost_arn                     = optional(string)

      propagating_vgws = optional(list(string))

      routes = optional(map(list(string)))
    }))

    secured = optional(object({
      name_prefix = optional(string)

      hosts = optional(number)

      cidr_blocks             = optional(list(string))
      map_public_ip_on_launch = optional(bool) # Default: false

      assign_ipv6_address_on_creation = optional(bool)         # Default: false
      ipv6_cidr_blocks                = optional(list(string)) # /64

      map_customer_owned_ip_on_launch = optional(bool) # Default: false
      customer_owned_ipv4_pool        = optional(list(string))
      outpost_arn                     = optional(string)

      propagating_vgws = optional(list(string))

      # nice to do: network_acl_cidr_blocks = optional(list(string))
      network_acl_cidr_block = optional(string)

      routes = optional(map(list(string)))
    }))

    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
    }))
  })

  validation {
    condition = var.subnets != null ? (
      var.subnets.availability_zones != null
      ? length(var.subnets.availability_zones) > 0
      ? var.subnets.availability_zone_ids != null
      ? length(var.subnets.availability_zone_ids) == 0
    : true : true : true) : true

    error_message = "The only possible values are \"availability_zones\" or \"availability_zone_ids\"."
  }

  default = null
}


locals {
  enable_subnets = var.enable && var.subnets != null

  #!не работает: if var.subnets.availability_zone_ids == null, то и local.availability_zone_ids будет null, а должно - []
  #availability_zone_ids = try(var.subnets.availability_zone_ids, [])

  # Have been simplified due to validation {} in variable "subnets" {} validation above
  # availability_zone_enabled = length(local.availability_zones) > 0
  # availability_zone_id_enabled = !local.availability_zone_enabled && length(local.availability_zone_ids) > 0
  availability_zones = local.enable_subnets ? (
    var.subnets.availability_zones != null ? var.subnets.availability_zones : []
  ) : []

  availability_zone_ids = local.enable_subnets ? (
    var.subnets.availability_zone_ids != null ? var.subnets.availability_zone_ids : []
  ) : []

  keys = try(coalescelist(local.availability_zones, local.availability_zone_ids), [])

  vpc_cidr_prefix = local.enable_subnets ? tonumber(replace(var.vpc_cidr_block, "/.*\\//", "")) : 0

  subnets_order = local.enable_subnets ? [
    for v in var.subnets_order : v if var.subnets[v] != null
  ] : []

  cidr_chunks = local.enable_subnets ? chunklist(
    cidrsubnets(var.vpc_cidr_block, flatten([for v in local.subnets_order : [
      for vv in local.keys : var.max_ipv4_prefix - local.vpc_cidr_prefix - (
        var.subnets[v].hosts != null ? ceil(log(var.subnets[v].hosts, 2)
        ) : ceil(log(var.hosts[v], 2))
      )
  ]])...), length(local.keys)) : [[]]

  subnets = { for v in [
    for v in setproduct(local.subnets_order, [
      for v in local.keys : substr(v, -1, 1)
    ]) : join(module.const.delimiter, v)
    ] : v => {
    subnet     = split(module.const.delimiter, v)[0]
    zone_index = index([for v in local.keys : substr(v, -1, 1)], substr(v, -1, 1))
    cidr_block = element(
      var.subnets[split(module.const.delimiter, v)[0]].cidr_blocks != null
      ? var.subnets[split(module.const.delimiter, v)[0]].cidr_blocks
      : element(local.cidr_chunks, index(local.subnets_order, split(module.const.delimiter, v)[0])),
      index([for v in local.keys : substr(v, -1, 1)], substr(v, -1, 1))
    )
    map_public_ip_on_launch_default = lower(split(module.const.delimiter, v)[0]) == "public"
  } }

  # ["misc:tgw-06773499e1535c4e9:172.16.0.0/19", "public:igw-0268538b8344a2655:0.0.0.0/0"]
  routes = toset(local.enable_subnets ? flatten([
    for id in local.subnets_order : [
      for k, v in var.subnets[id].routes : [for list in setproduct([id], [k], v) : join(":", list)]
    ] if var.subnets[id].routes != null
  ]) : [])
}

