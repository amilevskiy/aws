variable "subnets" {
  type = object({
    name_prefix = optional(string)

    availability_zones    = optional(list(string))
    availability_zone_ids = optional(list(string))

    map_public_ip_on_launch         = optional(bool)   # Defaults false
    assign_ipv6_address_on_creation = optional(bool)   # Defaults false
    ipv6_cidr_block                 = optional(string) # /64

    # intentionally omit support of the following due to lack of testing?
    map_customer_owned_ip_on_launch = optional(bool) # Defaults false
    customer_owned_ipv4_pool        = optional(list(string))
    outpost_arn                     = optional(string)

    propagating_vgws = optional(list(string))

    public = optional(object({
      name_prefix = optional(string)

      cidr_blocks             = optional(list(string))
      map_public_ip_on_launch = optional(bool) # Defaults false

      assign_ipv6_address_on_creation = optional(bool)         # Defaults false
      ipv6_cidr_blocks                = optional(list(string)) # /64

      map_customer_owned_ip_on_launch = optional(bool) # Defaults false
      customer_owned_ipv4_pool        = optional(list(string))
      outpost_arn                     = optional(string)

      propagating_vgws = optional(list(string))
    }))

    private = optional(object({
      name_prefix = optional(string)

      cidr_blocks             = optional(list(string))
      map_public_ip_on_launch = optional(bool) # Defaults false

      assign_ipv6_address_on_creation = optional(bool)         # Defaults false
      ipv6_cidr_blocks                = optional(list(string)) # /64

      map_customer_owned_ip_on_launch = optional(bool) # Defaults false
      customer_owned_ipv4_pool        = optional(list(string))
      outpost_arn                     = optional(string)

      propagating_vgws = optional(list(string))
    }))

    secured = optional(object({
      name_prefix = optional(string)

      cidr_blocks             = optional(list(string))
      map_public_ip_on_launch = optional(bool) # Defaults false

      assign_ipv6_address_on_creation = optional(bool)         # Defaults false
      ipv6_cidr_blocks                = optional(list(string)) # /64

      map_customer_owned_ip_on_launch = optional(bool) # Defaults false
      customer_owned_ipv4_pool        = optional(list(string))
      outpost_arn                     = optional(string)

      propagating_vgws = optional(list(string))
    }))

    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
    }))
  })

  validation {
    condition = var.subnets != null ? lookup(
      var.subnets, "availability_zones", null
      ) != null ? length(var.subnets.availability_zones) > 0 ? lookup(
      var.subnets, "availability_zone_ids", null
    ) != null ? length(var.subnets.availability_zone_ids) == 0 : true : true : true : true

    error_message = "The only possible values are \"availability_zones\" or \"availability_zone_ids\"."
  }

  default = null
}


locals {
  #!не работает: if var.subnets.availability_zone_ids == null, то и local.availability_zone_ids будет null, а должно - []
  #availability_zone_ids = try(var.subnets.availability_zone_ids, [])

  availability_zones = var.subnets != null ? lookup(
    var.subnets, "availability_zones", null
  ) != null ? var.subnets.availability_zones : [] : []

  availability_zone_ids = var.subnets != null ? lookup(
    var.subnets, "availability_zone_ids", null
  ) != null ? var.subnets.availability_zone_ids : [] : []

  # simplify due to validation {} in variable "subnets" {} validation above
  # availability_zone_enabled = length(local.availability_zones) > 0
  # availability_zone_id_enabled = !local.availability_zone_enabled && length(local.availability_zone_ids) > 0

  keys = try(coalescelist(local.availability_zones, local.availability_zone_ids), [])


  public_cidr_blocks = local.enable_vpc > 0 && var.subnets != null ? lookup(
    var.subnets, "public", null
    ) != null ? lookup(
    var.subnets.public, "cidr_blocks", null
  ) != null ? var.subnets.public.cidr_blocks : [for v in local.keys : null] : [] : []

  private_cidr_blocks = local.enable_vpc > 0 && var.subnets != null ? lookup(
    var.subnets, "private", null
    ) != null ? lookup(
    var.subnets.private, "cidr_blocks", null
  ) != null ? var.subnets.private.cidr_blocks : [for v in local.keys : null] : [] : []

  secured_cidr_blocks = local.enable_vpc > 0 && var.subnets != null ? lookup(
    var.subnets, "secured", null
    ) != null ? lookup(
    var.subnets.secured, "cidr_blocks", null
  ) != null ? var.subnets.secured.cidr_blocks : [for v in local.keys : null] : [] : []

  public_length  = length(local.public_cidr_blocks) > 0 ? min(length(local.public_cidr_blocks), length(local.keys)) : length(local.keys)
  private_length = length(local.private_cidr_blocks) > 0 ? min(length(local.private_cidr_blocks), length(local.keys)) : length(local.keys)
  secured_length = length(local.secured_cidr_blocks) > 0 ? min(length(local.secured_cidr_blocks), length(local.keys)) : length(local.keys)

  plus_bits = local.public_length + local.private_length + local.secured_length > 0 ? ceil(log(local.public_length + local.private_length + local.secured_length, 2)) : 0


  public_subnets = local.enable_vpc > 0 && var.subnets != null ? lookup(
    var.subnets, "public", null
    ) != null ? zipmap(
    [for i, v in local.keys : replace(v, "/.*(.)$/", "$1") if i < local.public_length],
    [for i, v in local.public_cidr_blocks : i if i < local.public_length]
  ) : {} : {}

  private_subnets = local.enable_vpc > 0 && var.subnets != null ? lookup(
    var.subnets, "private", null
    ) != null ? zipmap(
    [for i, v in local.keys : replace(v, "/.*(.)$/", "$1") if i < local.private_length],
    [for i, v in local.private_cidr_blocks : i if i < local.private_length]
  ) : {} : {}

  secured_subnets = local.enable_vpc > 0 && var.subnets != null ? lookup(
    var.subnets, "secured", null
    ) != null ? zipmap(
    [for i, v in local.keys : replace(v, "/.*(.)$/", "$1") if i < local.secured_length],
    [for i, v in local.secured_cidr_blocks : i if i < local.secured_length]
  ) : {} : {}
}
