#https://www.terraform.io/docs/providers/aws/r/network_acl.html
resource "aws_network_acl" "this" {
  #################################
  for_each = toset(local.subnets_order)

  vpc_id = aws_vpc.this[0].id

  subnet_ids = [
    for k, v in aws_subnet.this : v.id if can(regex(join(each.key, ["^", module.const.delimiter]), k))
  ]

  tags = merge(local.tags, {
    Name = join(module.const.delimiter, [var.subnets[each.key].name_prefix != null ? (
      var.subnets[each.key].name_prefix
      ) : var.subnets.name_prefix != null ? var.subnets.name_prefix : join(module.const.delimiter, [
        local.prefix,
        var.label[each.key]
      ]),
      module.const.acl_suffix,
    ])
  })
}

#https://www.terraform.io/docs/providers/aws/r/network_acl_rule.html
resource "aws_network_acl_rule" "ingress" {
  #########################################
  for_each = toset(local.subnets_order)

  network_acl_id = aws_network_acl.this[each.key].id

  # egress      = false
  rule_number = module.const.last_rule_number
  rule_action = "allow"
  protocol    = "-1"

  cidr_block = each.key == "secured" ? lookup(
    var.subnets.secured, "network_acl_cidr_block", null
  ) != null ? var.subnets.secured.network_acl_cidr_block : aws_vpc.this[0].cidr_block : module.const.cidr_any
}

#https://www.terraform.io/docs/providers/aws/r/network_acl_rule.html
resource "aws_network_acl_rule" "egress" {
  ########################################
  for_each = toset(local.subnets_order)

  network_acl_id = aws_network_acl.this[each.key].id

  egress      = true
  rule_number = module.const.last_rule_number
  rule_action = "allow"
  protocol    = "-1"

  cidr_block = each.key == "secured" ? lookup(
    var.subnets.secured, "network_acl_cidr_block", null
  ) != null ? var.subnets.secured.network_acl_cidr_block : aws_vpc.this[0].cidr_block : module.const.cidr_any
}
