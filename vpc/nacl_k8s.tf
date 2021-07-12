#https://www.terraform.io/docs/providers/aws/r/network_acl.html
resource "aws_network_acl" "k8s" {
  ################################
  count = length(local.k8s_subnets) > 0 ? 1 : 0

  vpc_id     = aws_vpc.this[0].id
  subnet_ids = [for k, v in aws_subnet.k8s : v.id]

  tags = merge(local.tags, {
    Name = join(module.const.delimiter, [lookup(
      var.subnets.k8s, "name_prefix", null
      ) != null ? var.subnets.k8s.name_prefix : lookup(
      var.subnets, "name_prefix", null
      ) != null ? var.subnets.name_prefix : "${local.prefix}${module.const.delimiter}${var.k8s_label}",
      module.const.acl_suffix,
    ])
  })
}

#https://www.terraform.io/docs/providers/aws/r/network_acl_rule.html
resource "aws_network_acl_rule" "k8s_ingress" {
  #############################################
  count = length(local.k8s_subnets) > 0 ? 1 : 0

  network_acl_id = aws_network_acl.k8s[0].id

  # egress      = false
  rule_number = module.const.last_rule_number
  rule_action = "allow"
  protocol    = "-1"
  cidr_block  = module.const.cidr_any
}

#https://www.terraform.io/docs/providers/aws/r/network_acl_rule.html
resource "aws_network_acl_rule" "k8s_egress" {
  ############################################
  count = length(local.k8s_subnets) > 0 ? 1 : 0

  network_acl_id = aws_network_acl.k8s[0].id

  egress      = true
  rule_number = module.const.last_rule_number
  rule_action = "allow"
  protocol    = "-1"
  cidr_block  = module.const.cidr_any
}
