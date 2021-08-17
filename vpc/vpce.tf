variable "vpc_endpoint" {
  type = object({
    name_prefix = optional(string)

    region = optional(string)

    services = optional(map(object({
      name = optional(string)

      region              = optional(string)
      auto_accept         = optional(bool)
      policy              = optional(string)
      private_dns_enabled = optional(bool)
      vpc_endpoint_type   = optional(string)      # Gateway, GatewayLoadBalancer, Interface
      security_group_ids  = optional(set(string)) # Interface (required)
    })))

    timeouts = optional(object({
      create = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })

  default = null
}

locals {
  enable_vpc_endpoint = (local.enable_vpc > 0 && var.vpc_endpoint != null
    ? var.vpc_endpoint.services != null
  ? 1 : 0 : 0)

  enable_data_region = (local.enable_vpc_endpoint > 0
    ? var.vpc_endpoint.region == null
    ? alltrue([for k, v in var.vpc_endpoint.services : can(coalesce(v.region))])
  ? 0 : 1 : 0 : 0)

  vpc_endpoint_security_groups = toset(local.enable_vpc_endpoint > 0 ? [
    for k, v in var.vpc_endpoint.services : k if(
      coalesce(v.vpc_endpoint_type, "Gateway") == "Interface" && v.security_group_ids == null
  )] : [])

  vpc_endpoint_subnet = try([
    for v in ["secured", "lb", "misc", "k8s", "public"] : v if contains(local.subnets_order, v)
  ][0], "")

  vpc_endpoints = local.enable_vpc_endpoint > 0 ? {
    for k, v in var.vpc_endpoint.services : "${k}:${coalesce(
      v.region,
      var.vpc_endpoint.region,
      join("", data.aws_region.this.*.name)
    )}" => v
  } : {}
}


#https://www.terraform.io/docs/providers/aws/d/region.html
data "aws_region" "this" {
  ########################
  count = local.enable_data_region
}

#https://www.terraform.io/docs/providers/aws/r/security_group.html
resource "aws_security_group" "this" {
  ####################################
  for_each = local.vpc_endpoint_security_groups

  name_prefix = "${local.prefix}${module.const.delimiter}${each.key}${module.const.delimiter}${module.const.sg_suffix}${module.const.delimiter}"
  description = "Traffic for ${each.key} VPC endpoint in ${aws_vpc.this[0].id}"

  vpc_id = aws_vpc.this[0].id

  tags = merge(local.tags, {
    Name = "${local.prefix}${module.const.delimiter}${each.key}${module.const.delimiter}${module.const.sg_suffix}"
  })

  dynamic "timeouts" {
    for_each = var.vpc_endpoint.timeouts != null ? [var.vpc_endpoint.timeouts] : []
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [ingress, egress]
  }
}

#https://www.terraform.io/docs/providers/aws/r/security_group_rule.html
resource "aws_security_group_rule" "this" {
  #########################################
  for_each = local.vpc_endpoint_security_groups

  security_group_id = aws_security_group.this[each.key].id

  type        = "ingress"
  protocol    = "-1"
  cidr_blocks = aws_vpc.this.*.cidr_block
  from_port   = 0
  to_port     = 0

  description = "Allow all from ${aws_vpc.this[0].id}"

  lifecycle {
    create_before_destroy = true
  }
}


#https://www.terraform.io/docs/providers/aws/r/vpc_endpoint.html
resource "aws_vpc_endpoint" "this" {
  ##################################
  for_each = local.vpc_endpoints

  vpc_id = aws_vpc.this[0].id

  # com.amazonaws.<region>.<service> | aws.sagemaker.<region>.notebook
  service_name = (split(":", each.key)[0] != "sagemaker"
    ? join(".", concat(["com.amazonaws"], reverse(split(":", each.key))))
    : join(".", concat(["aws"], split(":", each.key), ["notebook"]))
  )

  auto_accept         = each.value.auto_accept
  policy              = each.value.policy
  private_dns_enabled = each.value.private_dns_enabled

  vpc_endpoint_type = each.value.vpc_endpoint_type # Gateway, GatewayLoadBalancer, Interface

  route_table_ids = (coalesce(each.value.vpc_endpoint_type, "Gateway") == "Gateway"
    ? [for k, v in aws_route_table.this : v.id]
  : null)

  security_group_ids = (each.value.security_group_ids != null
    ? each.value.security_group_ids
    : coalesce(each.value.vpc_endpoint_type, "Gateway") == "Interface"
    ? [aws_security_group.this[split(":", each.key)[0]].id]
  : null) # Interface (required)

  subnet_ids = (contains(["GatewayLoadBalancer", "Interface"], coalesce(each.value.vpc_endpoint_type, "Gateway"))
    ? [for k, v in aws_subnet.this : v.id if can(regex(join(local.vpc_endpoint_subnet, ["^", module.const.delimiter]), k))]
    : null
  ) # GatewayLoadBalancer, Interface

  tags = merge(local.tags, {
    Name = coalesce(each.value.name, join(module.const.delimiter, [
      local.prefix,
      split(":", each.key)[0],
      module.const.vpc_endpoint_suffix
    ]))
  })

  dynamic "timeouts" {
    for_each = var.vpc_endpoint.timeouts != null ? [var.vpc_endpoint.timeouts] : []
    content {
      create = timeouts.value.create
      update = timeouts.value.create
      delete = timeouts.value.delete
    }
  }

  depends_on = [aws_security_group.this]
}
