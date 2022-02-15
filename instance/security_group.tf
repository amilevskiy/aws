variable "security_group" {
  type = object({
    name        = optional(string)
    description = optional(string)

    vpc_id                = optional(string)
    enable_rule_embedding = optional(bool)

    ingress = optional(list(string))
    egress  = optional(list(string))

    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
    }))
  })

  default = null
}

locals {
  enable_sg = var.enable && var.security_group != null ? var.instance != null ? (
    var.instance.vpc_security_group_ids != null
  ) ? var.instance.vpc_security_group_ids != "" ? 0 : 1 : 1 : 1 : 0

  security_group_name = local.enable_sg > 0 ? var.security_group.name != null ? (
    var.security_group.name
  ) : "${local.instance_name}${module.const.delimiter}${module.const.sg_suffix}" : null

  enable_rule_embedding = (local.enable_sg > 0
    ? var.security_group.enable_rule_embedding != null
    ? var.security_group.enable_rule_embedding
  : false : false)

  # 0   1                       2  3   4
  # tcp 10.1.1.1/20,10.2.1.2/20 80 443 description name
  security_group_rules = local.enable_sg > 0 && !local.enable_rule_embedding ? merge(
    var.security_group.ingress != null ? {
      for i, v in var.security_group.ingress : replace(replace(
        "${v} * * * *",
        "/^\\s*(\\S+)\\s+(\\S+)\\s+(\\S+)\\s+(\\S+).*/",
        "ingress $1 $2 $3 $4"
      ), "/[ *]+$/", "") => split(" ", replace(v, "/\\s+/", " "))
    } : {},
    var.security_group.egress != null ? {
      for i, v in var.security_group.egress : replace(replace(
        "${v} * * * *",
        "/^\\s*(\\S+)\\s+(\\S+)\\s+(\\S+)\\s+(\\S+).*/",
        "egress $1 $2 $3 $4"
      ), "/[ *]+$/", "") => split(" ", replace(v, "/\\s+/", " "))
  } : {}) : {}

  security_group_ingress_rules = (local.enable_sg > 0 && local.enable_rule_embedding
    ? var.security_group.ingress != null
    ? [for i, v in var.security_group.ingress : split(" ", replace(v, "/\\s+/", " "))]
  : [] : [])

  security_group_egress_rules = (local.enable_sg > 0 && local.enable_rule_embedding
    ? var.security_group.egress != null
    ? [for i, v in var.security_group.egress : split(" ", replace(v, "/\\s+/", " "))]
  : [] : [])
}

#https://www.terraform.io/docs/providers/aws/r/security_group
resource "aws_security_group" "this" {
  ####################################
  count = local.enable_sg

  name_prefix = "${local.security_group_name}${module.const.delimiter}"
  description = var.security_group.description != null ? (
    var.security_group.description
  ) : "Traffic for ${local.instance_name}"

  vpc_id = var.security_group.vpc_id

  # 0   1                       2  3   4
  # tcp 10.1.1.1/20,10.2.1.2/20 80 443 description
  dynamic "ingress" {
    for_each = local.security_group_ingress_rules != null ? local.security_group_ingress_rules : []
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
    for_each = local.security_group_egress_rules != null ? local.security_group_egress_rules : []
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

  dynamic "timeouts" {
    for_each = var.security_group.timeouts != null ? [var.security_group.timeouts] : []
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
    }
  }

  tags = {
    Name = local.security_group_name
  }

  lifecycle {
    create_before_destroy = true
  }
}

#https://www.terraform.io/docs/providers/aws/r/security_group_rule
resource "aws_security_group_rule" "this" {
  #########################################
  for_each = local.security_group_rules

  security_group_id = aws_security_group.this[0].id

  # 0   1                       2  3   4
  # tcp 10.1.1.1/20,10.2.1.2/20 80 443 description name
  type     = split(" ", each.key)[0]
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
