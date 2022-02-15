variable "enable_security_group_rule_embedding" {
  default     = false
  description = "If true then rules will be embedded into \"aws_security_group\" resource"
}

variable "security_groups" {
  type = map(object({
    description            = optional(string)
    revoke_rules_on_delete = optional(bool)

    ingress = optional(list(string))
    egress  = optional(list(string))
  }))

  default = null

  description = "The list of security group objects"
}

locals {
  security_groups = var.enable && var.security_groups != null ? {
    for k, v in var.security_groups : k => {
      description            = var.security_groups[k].description
      revoke_rules_on_delete = var.security_groups[k].revoke_rules_on_delete
      ingress                = [for vv in v.ingress : split(" ", replace(vv, "/\\s+/", " "))]
      egress                 = [for vv in v.egress : split(" ", replace(vv, "/\\s+/", " "))]
    }
  } : {}

  inbound_sg_rules = var.enable_security_group_rule_embedding ? {} : merge(flatten([
    for k, v in local.security_groups : { for vv in v.ingress : "${k}:${join(" ", slice(concat(
      ["ingress"], vv, ["*", "*", "*", "*"]
    ), 0, 5))}" => vv }
  ])...)

  outbound_sg_rules = var.enable_security_group_rule_embedding ? {} : merge(flatten([
    for k, v in local.security_groups : { for vv in v.egress : "${k}:${join(" ", slice(concat(
      ["egress"], vv, ["*", "*", "*", "*"]
    ), 0, 5))}" => vv }
  ])...)

  security_group_rules = merge(local.inbound_sg_rules, local.outbound_sg_rules)
}

#https://www.terraform.io/docs/providers/aws/r/security_group
resource "aws_security_group" "this" {
  ####################################
  for_each = local.security_groups

  name        = substr(each.key, length(each.key) - 1, 1) != module.const.delimiter ? each.key : null
  name_prefix = substr(each.key, length(each.key) - 1, 1) == module.const.delimiter ? each.key : null

  # each.value.description != null ? each.value.description : "${each.key} for ${var.vpc_id}"
  description = coalesce(
    each.value.description,
    "${trimsuffix(each.key, module.const.delimiter)} for ${aws_vpc.this[0].id}"
  )

  revoke_rules_on_delete = each.value.revoke_rules_on_delete

  vpc_id = aws_vpc.this[0].id

  # 0   1                       2  3   4
  # tcp 10.1.1.1/20,10.2.1.2/20 80 443 description
  dynamic "ingress" {
    for_each = var.enable_security_group_rule_embedding && each.value.ingress != null ? each.value.ingress : []
    content {
      protocol = can(ingress.value[0]) ? ingress.value[0] != "*" ? ingress.value[0] : "-1" : "-1"

      self            = can(regex("^(?i)self$", ingress.value[1])) ? true : null
      prefix_list_ids = can(regex("^pl-", ingress.value[1])) ? split(",", ingress.value[1]) : []
      security_groups = can(regex("^sg-", ingress.value[1])) ? split(",", ingress.value[1]) : null

      cidr_blocks = can(regex("^[0-9./,]+$", ingress.value[1])) ? [
        for v in split(",", ingress.value[1]) : replace("${v}/32", "/^([0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+\\/[0-9]+).*/", "$1")
      ] : can(regex("^((?i)self$|pl-|sg-)", ingress.value[1])) ? null : [module.const.cidr_any]

      # ipv6_cidr_blocks = can(ingress.value[1]) ? can(regex("^((?i)self$|pl-|sg-|[0-9./,]+$)", ingress.value[1])) ? null : split(",", ingress.value[1]) : null
      ipv6_cidr_blocks = []

      from_port = try(tonumber(ingress.value[2]), 0)
      to_port   = try(tonumber(ingress.value[3]), try(tonumber(ingress.value[2]), 0))

      description = length(ingress.value) > 4 ? join(" ", slice(ingress.value, 4, length(ingress.value))) : null
    }
  }

  dynamic "egress" {
    for_each = var.enable_security_group_rule_embedding && each.value.egress != null ? each.value.egress : []
    content {
      protocol = can(egress.value[0]) ? egress.value[0] != "*" ? egress.value[0] : "-1" : "-1"

      self            = can(regex("^(?i)self$", egress.value[1])) ? true : null
      prefix_list_ids = can(regex("^pl-", egress.value[1])) ? split(",", egress.value[1]) : []
      security_groups = can(regex("^sg-", egress.value[1])) ? split(",", egress.value[1]) : null

      cidr_blocks = can(regex("^[0-9./,]+$", egress.value[1])) ? [
        for v in split(",", egress.value[1]) : replace("${v}/32", "/^([0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+\\/[0-9]+).*/", "$1")
      ] : can(regex("^((?i)self$|pl-|sg-)", egress.value[1])) ? null : [module.const.cidr_any]

      # ipv6_cidr_blocks = can(egress.value[1]) ? can(regex("^((?i)self$|pl-|sg-|[0-9./,]+$)", egress.value[1])) ? null : split(",", egress.value[1]) : null
      ipv6_cidr_blocks = []

      from_port = try(tonumber(egress.value[2]), 0)
      to_port   = try(tonumber(egress.value[3]), try(tonumber(egress.value[2]), 0))

      description = length(egress.value) > 4 ? join(" ", slice(egress.value, 4, length(egress.value))) : null
    }
  }

  tags = merge(local.tags, { Name = join(module.const.delimiter, [
    local.prefix, trimsuffix(each.key, module.const.delimiter), module.const.sg_suffix
  ]) })
}

#https://www.terraform.io/docs/providers/aws/r/security_group_rule
resource "aws_security_group_rule" "this" {
  #########################################
  for_each = local.security_group_rules

  security_group_id = aws_security_group.this[split(":", each.key)[0]].id

  # 0       1   2                       3  4   5
  # ingress tcp 10.1.1.1/20,10.2.1.2/20 80 443 description name
  type = replace(each.key, "/.*:(\\S+).*/", "$1")

  protocol = can(each.value[0]) ? each.value[0] != "*" ? each.value[0] : "-1" : "-1"

  self                     = can(regex("^(?i)self$", each.value[1])) ? true : null
  prefix_list_ids          = can(regex("^pl-", each.value[1])) ? split(",", each.value[1]) : []
  source_security_group_id = can(regex("^sg-", each.value[1])) ? each.value[1] : null

  cidr_blocks = can(regex("^[0-9./,]+$", each.value[1])) ? [
    for v in split(",", each.value[1]) : replace("${v}/32", "/^([0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+\\/[0-9]+).*/", "$1")
  ] : can(regex("^((?i)self$|pl-|sg-)", each.value[1])) ? null : [module.const.cidr_any]

  # ipv6_cidr_blocks = can(each.value[1]) ? can(regex("^((?i)self$|pl-|sg-|[0-9./,]+$)", each.value[1])) ? null : split(",", each.value[1]) : null
  ipv6_cidr_blocks = []

  from_port = try(tonumber(each.value[2]), 0)
  to_port   = try(tonumber(each.value[3]), try(tonumber(each.value[2]), 0))

  description = length(each.value) > 3 ? join(" ", slice(each.value, 4, length(each.value))) : null

  lifecycle {
    create_before_destroy = true
  }
}
