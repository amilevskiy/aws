#https://www.terraform.io/docs/providers/aws/r/network_acl.html
resource "aws_network_acl" "this" {
  #################################
  for_each = local.subnets

  vpc_id = local.vpc_id

  subnet_ids = [aws_subnet.this[each.key].id]

  tags = merge(local.tags, {
    Name = join(module.const.delimiter, compact([
      "NACL-",
      local.tf_stack,
      each.key
    ]))
  })
}

#https://www.terraform.io/docs/providers/aws/r/network_acl_rule.html
resource "aws_network_acl_rule" "ingress" {
  #########################################
  for_each = local.inbound_network_acls

  network_acl_id = aws_network_acl.this[replace(each.key, format("/%s[^%s]+/", module.const.delimiter, module.const.delimiter), "")].id

  # egress      = false
  rule_number = tonumber(replace(each.key, format("/.*%s/", module.const.delimiter), ""))
  rule_action = each.value[0]
  protocol    = replace(try(each.value[1], "-1"), "/^\\*+$/", "-1")

  cidr_block = can(each.value[2]) ? each.value[2] != "*" ? each.value[2] : module.const.cidr_any : module.const.cidr_any
  from_port  = try(each.value[1], "-1") != "icmp" ? try(tonumber(each.value[3]), 0) : null
  to_port    = try(each.value[1], "-1") != "icmp" ? try(tonumber(each.value[4]), try(tonumber(each.value[3]), 0)) : null
  icmp_type  = try(each.value[1], "-1") == "icmp" ? try(each.value[3], "-1") : null
  icmp_code  = try(each.value[1], "-1") == "icmp" ? try(each.value[4], "-1") : null
}


#https://www.terraform.io/docs/providers/aws/r/network_acl_rule.html
resource "aws_network_acl_rule" "egress" {
  ########################################
  for_each = local.outbound_network_acls

  network_acl_id = aws_network_acl.this[replace(each.key, format("/%s[^%s]+/", module.const.delimiter, module.const.delimiter), "")].id

  egress      = true
  rule_number = tonumber(replace(each.key, format("/.*%s/", module.const.delimiter), ""))
  rule_action = each.value[0]
  protocol    = replace(try(each.value[1], "-1"), "/^\\*+$/", "-1")

  cidr_block = can(each.value[2]) ? each.value[2] != "*" ? each.value[2] : module.const.cidr_any : module.const.cidr_any
  from_port  = try(each.value[1], "-1") != "icmp" ? try(tonumber(each.value[3]), 0) : null
  to_port    = try(each.value[1], "-1") != "icmp" ? try(tonumber(each.value[4]), try(tonumber(each.value[3]), 0)) : null
  icmp_type  = try(each.value[1], "-1") == "icmp" ? try(each.value[3], "-1") : null
  icmp_code  = try(each.value[1], "-1") == "icmp" ? try(each.value[4], "-1") : null
}
