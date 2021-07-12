variable "security_group" {
  type = object({
    name        = optional(string)
    description = optional(string)

    vpc_id = optional(string)

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
  enable_sg = var.enable && var.security_group != null ? var.instance != null ? lookup(
    var.instance, "vpc_security_group_ids", null
  ) != null ? var.instance.vpc_security_group_ids != "" ? 0 : 1 : 1 : 1 : 0

  security_group_name = local.enable_sg > 0 ? lookup(
    var.security_group, "name", null
  ) != null ? var.security_group.name : "${local.instance_name}${module.const.delimiter}${module.const.sg_suffix}" : null

  # 0   1                       2  3   4
  # tcp 10.1.1.1/20,10.2.1.2/20 80 443 description name
  security_group_rules = local.enable_sg > 0 ? merge(
    lookup(var.security_group, "ingress", null) != null ? {
      for i, v in var.security_group.ingress : replace(replace(
        "${v} * * * *",
        "/^\\s*(\\S+)\\s+(\\S+)\\s+(\\S+)\\s+(\\S+).*/",
        "ingress $1 $2 $3 $4"
      ), "/[ *]+$/", "") => split(" ", replace(v, "/\\s+/", " "))
    } : {},
    lookup(var.security_group, "egress", null) != null ? {
      for i, v in var.security_group.egress : replace(replace(
        "${v} * * * *",
        "/^\\s*(\\S+)\\s+(\\S+)\\s+(\\S+)\\s+(\\S+).*/",
        "egress $1 $2 $3 $4"
      ), "/[ *]+$/", "") => split(" ", replace(v, "/\\s+/", " "))
  } : {}) : {}
}

#https://www.terraform.io/docs/providers/aws/r/security_group.html
resource "aws_security_group" "this" {
  ####################################
  count = local.enable_sg

  name_prefix = "${local.security_group_name}${module.const.delimiter}"
  description = lookup(
    var.security_group, "description", null
  ) != null ? var.security_group.description : "Traffic for ${local.instance_name}"

  vpc_id = lookup(var.security_group, "vpc_id", null)

  dynamic "timeouts" {
    for_each = lookup(var.security_group, "timeouts", null) == null ? [] : [var.security_group.timeouts]
    content {
      create = lookup(timeouts.value, "create", null)
      delete = lookup(timeouts.value, "delete", null)
    }
  }

  tags = {
    Name = local.security_group_name
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [ingress, egress]
  }
}

#https://www.terraform.io/docs/providers/aws/r/security_group_rule.html
resource "aws_security_group_rule" "this" {
  #########################################
  for_each = local.security_group_rules

  security_group_id = aws_security_group.this[0].id

  # 0   1                       2  3   4
  # tcp 10.1.1.1/20,10.2.1.2/20 80 443 description name
  type     = split(" ", each.key)[0]
  protocol = can(each.value[0]) ? each.value[0] != "*" ? each.value[0] : "-1" : "-1"

  self                     = can(regex("^(?i)self$", each.value[1])) ? true : null
  prefix_list_ids          = can(regex("^pl-", each.value[1])) ? split(",", each.value[1]) : null
  source_security_group_id = can(regex("^sg-", each.value[1])) ? each.value[1] : null

  cidr_blocks = can(regex("^[0-9./,]+$", each.value[1])) ? [
    for v in split(",", each.value[1]) : replace("${v}/32", "/^([0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+\\/[0-9]+).*/", "$1")
  ] : can(regex("^((?i)self$|pl-|sg-)", each.value[1])) ? null : [module.const.cidr_any]

  # ipv6_cidr_blocks = can(each.value[1]) ? can(regex("^((?i)self$|pl-|sg-|[0-9./,]+$)", each.value[1])) ? null : split(",", each.value[1]) : null

  from_port = try(tonumber(each.value[2]), 0)
  to_port   = try(tonumber(each.value[3]), try(tonumber(each.value[2]), 0))

  description = length(each.value) > 4 ? join(" ", slice(each.value, 4, length(each.value))) : null

  lifecycle {
    create_before_destroy = true
  }
}
