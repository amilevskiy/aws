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

#
#https://www.terraform.io/docs/providers/aws/r/subnet.html
resource "aws_subnet" "public" {
  ##############################
  for_each = local.public_subnets

  vpc_id = aws_vpc.this[0].id

  cidr_block = lookup(
    var.subnets.public, "cidr_blocks", null
    ) != null ? element(var.subnets.public.cidr_blocks, each.value
  ) : cidrsubnet(var.vpc.cidr_block, local.plus_bits, each.value)

  availability_zone    = length(local.availability_zones) > 0 ? element(local.availability_zones, each.value) : null
  availability_zone_id = length(local.availability_zone_ids) > 0 ? element(local.availability_zone_ids, each.value) : null

  #-map_public_ip_on_launch = lookup(var.subnets.public, "map_public_ip_on_launch", lookup(var.subnets, "map_public_ip_on_launch", true))
  map_public_ip_on_launch = lookup(
    var.subnets.public, "map_public_ip_on_launch", null
    ) != null ? var.subnets.public.map_public_ip_on_launch : lookup(
    var.subnets, "map_public_ip_on_launch", null
  ) != null ? var.subnets.map_public_ip_on_launch : true

  # ipv6
  assign_ipv6_address_on_creation = lookup(
    var.subnets.public, "assign_ipv6_address_on_creation", null
    ) != null ? var.subnets.public.assign_ipv6_address_on_creation : lookup(
    var.subnets, "assign_ipv6_address_on_creation", null
  ) != null ? var.subnets.assign_ipv6_address_on_creation : null

  ipv6_cidr_block = lookup(
    var.subnets.public, "ipv6_cidr_block", null
  ) != null ? element(var.subnets.public.ipv6_cidr_block, each.value) : null

  # customer_owned_ip
  map_customer_owned_ip_on_launch = lookup(
    var.subnets.public, "map_customer_owned_ip_on_launch", null
    ) != null ? var.subnets.public.map_customer_owned_ip_on_launch : lookup(
    var.subnets, "map_customer_owned_ip_on_launch", null
  ) != null ? var.subnets.map_customer_owned_ip_on_launch : null

  customer_owned_ipv4_pool = lookup(
    var.subnets.public, "customer_owned_ipv4_pool", null
  ) != null ? element(var.subnets.public.customer_owned_ipv4_pool, each.value) : null

  outpost_arn = lookup(
    var.subnets.public, "outpost_arn", null
    ) != null ? var.subnets.public.outpost_arn : lookup(
    var.subnets, "outpost_arn", null
  ) != null ? var.subnets.outpost_arn : null

  #var.subnets.public.name_prefix is null
  #- try(var.subnets.public.name_prefix, var.subnets.name_prefix, local.prefix),
  #- can(var.subnets.public.name_prefix) ? var.subnets.public.name_prefix : local.prefix,
  tags = merge(var.tags, {
    Name = join(module.const.delimiter, [lookup(
      var.subnets.public, "name_prefix", null
      ) != null ? var.subnets.public.name_prefix : lookup(
      var.subnets, "name_prefix", null
      ) != null ? var.subnets.name_prefix : "${local.prefix}${module.const.delimiter}${var.public_label}",
      each.key,
      module.const.subnet_suffix,
    ])
  })

  dynamic "timeouts" {
    for_each = lookup(var.subnets, "timeouts", null) == null ? [] : [var.subnets.timeouts]
    content {
      create = lookup(timeouts.value, "create", null)
      delete = lookup(timeouts.value, "delete", null)
    }
  }
}


#
#https://www.terraform.io/docs/providers/aws/r/subnet.html
resource "aws_subnet" "private" {
  ###############################
  for_each = local.private_subnets

  vpc_id = aws_vpc.this[0].id

  cidr_block = lookup(
    var.subnets.private, "cidr_blocks", null
  ) != null ? element(var.subnets.private.cidr_blocks, each.value) : cidrsubnet(var.vpc.cidr_block, local.plus_bits, each.value + length(local.public_subnets))

  availability_zone    = length(local.availability_zones) > 0 ? element(local.availability_zones, each.value) : null
  availability_zone_id = length(local.availability_zone_ids) > 0 ? element(local.availability_zone_ids, each.value) : null

  map_public_ip_on_launch = lookup(
    var.subnets.private, "map_public_ip_on_launch", null
    ) != null ? var.subnets.private.map_public_ip_on_launch : lookup(
    var.subnets, "map_public_ip_on_launch", null
  ) != null ? var.subnets.map_public_ip_on_launch : null

  # ipv6
  assign_ipv6_address_on_creation = lookup(
    var.subnets.private, "assign_ipv6_address_on_creation", null
    ) != null ? var.subnets.private.assign_ipv6_address_on_creation : lookup(
    var.subnets, "assign_ipv6_address_on_creation", null
  ) != null ? var.subnets.assign_ipv6_address_on_creation : null

  ipv6_cidr_block = lookup(
    var.subnets.private, "ipv6_cidr_block", null
  ) != null ? element(var.subnets.private.ipv6_cidr_block, each.value) : null

  # customer_owned_ip
  map_customer_owned_ip_on_launch = lookup(
    var.subnets.private, "map_customer_owned_ip_on_launch", null
    ) != null ? var.subnets.private.map_customer_owned_ip_on_launch : lookup(
    var.subnets, "map_customer_owned_ip_on_launch", null
  ) != null ? var.subnets.map_customer_owned_ip_on_launch : null

  customer_owned_ipv4_pool = lookup(
    var.subnets.private, "customer_owned_ipv4_pool", null
  ) != null ? element(var.subnets.private.customer_owned_ipv4_pool, each.value) : null

  outpost_arn = lookup(
    var.subnets.private, "outpost_arn", null
    ) != null ? var.subnets.private.outpost_arn : lookup(
    var.subnets, "outpost_arn", null
  ) != null ? var.subnets.outpost_arn : null

  tags = merge(var.tags, {
    Name = join(module.const.delimiter, [lookup(
      var.subnets.private, "name_prefix", null
      ) != null ? var.subnets.private.name_prefix : lookup(
      var.subnets, "name_prefix", null
      ) != null ? var.subnets.name_prefix : "${local.prefix}${module.const.delimiter}${var.private_label}",
      each.key,
      module.const.subnet_suffix,
    ])
  })

  dynamic "timeouts" {
    for_each = lookup(var.subnets, "timeouts", null) == null ? [] : [var.subnets.timeouts]
    content {
      create = lookup(timeouts.value, "create", null)
      delete = lookup(timeouts.value, "delete", null)
    }
  }
}


#
#https://www.terraform.io/docs/providers/aws/r/subnet.html
resource "aws_subnet" "secured" {
  ###############################
  for_each = local.secured_subnets

  vpc_id = aws_vpc.this[0].id

  cidr_block = lookup(
    var.subnets.secured, "cidr_blocks", null
  ) != null ? element(var.subnets.secured.cidr_blocks, each.value) : cidrsubnet(var.vpc.cidr_block, local.plus_bits, each.value + length(local.public_subnets) + length(local.private_subnets))

  availability_zone    = length(local.availability_zones) > 0 ? element(local.availability_zones, each.value) : null
  availability_zone_id = length(local.availability_zone_ids) > 0 ? element(local.availability_zone_ids, each.value) : null

  map_public_ip_on_launch = lookup(
    var.subnets.secured, "map_public_ip_on_launch", null
    ) != null ? var.subnets.secured.map_public_ip_on_launch : lookup(
    var.subnets, "map_public_ip_on_launch", null
  ) != null ? var.subnets.map_public_ip_on_launch : null

  # ipv6
  assign_ipv6_address_on_creation = lookup(
    var.subnets.secured, "assign_ipv6_address_on_creation", null
    ) != null ? var.subnets.secured.assign_ipv6_address_on_creation : lookup(
    var.subnets, "assign_ipv6_address_on_creation", null
  ) != null ? var.subnets.assign_ipv6_address_on_creation : null

  ipv6_cidr_block = lookup(
    var.subnets.secured, "ipv6_cidr_block", null
  ) != null ? element(var.subnets.secured.ipv6_cidr_block, each.value) : null

  # customer_owned_ip
  map_customer_owned_ip_on_launch = lookup(
    var.subnets.secured, "map_customer_owned_ip_on_launch", null
    ) != null ? var.subnets.secured.map_customer_owned_ip_on_launch : lookup(
    var.subnets, "map_customer_owned_ip_on_launch", null
  ) != null ? var.subnets.map_customer_owned_ip_on_launch : null

  customer_owned_ipv4_pool = lookup(
    var.subnets.secured, "customer_owned_ipv4_pool", null
  ) != null ? element(var.subnets.secured.customer_owned_ipv4_pool, each.value) : null

  outpost_arn = lookup(
    var.subnets.secured, "outpost_arn", null
    ) != null ? var.subnets.secured.outpost_arn : lookup(
    var.subnets, "outpost_arn", null
  ) != null ? var.subnets.outpost_arn : null

  tags = merge(var.tags, {
    Name = join(module.const.delimiter, [lookup(
      var.subnets.secured, "name_prefix", null
      ) != null ? var.subnets.secured.name_prefix : lookup(
      var.subnets, "name_prefix", null
      ) != null ? var.subnets.name_prefix : "${local.prefix}${module.const.delimiter}${var.secured_label}",
      each.key,
      module.const.subnet_suffix,
    ])
  })

  dynamic "timeouts" {
    for_each = lookup(var.subnets, "timeouts", null) == null ? [] : [var.subnets.timeouts]
    content {
      create = lookup(timeouts.value, "create", null)
      delete = lookup(timeouts.value, "delete", null)
    }
  }
}
