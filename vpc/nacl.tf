#https://www.terraform.io/docs/providers/aws/r/network_acl.html
resource "aws_network_acl" "public" {
  ###################################
  count = length(local.public_subnets) > 0 ? 1 : 0

  vpc_id     = aws_vpc.this[0].id
  subnet_ids = [for k, v in aws_subnet.public : v.id]

  tags = merge(local.tags, {
    Name = join(module.const.delimiter, [lookup(
      var.subnets.public, "name_prefix", null
      ) != null ? var.subnets.public.name_prefix : lookup(
      var.subnets, "name_prefix", null
      ) != null ? var.subnets.name_prefix : "${local.prefix}${module.const.delimiter}${var.public_label}",
      module.const.acl_suffix,
    ])
  })
}

#https://www.terraform.io/docs/providers/aws/r/network_acl_rule.html
resource "aws_network_acl_rule" "public_ingress" {
  ################################################
  count = length(local.public_subnets) > 0 ? 1 : 0

  network_acl_id = aws_network_acl.public[0].id

  # egress      = false
  rule_number = module.const.last_rule_number
  rule_action = "allow"
  protocol    = "-1"
  cidr_block  = module.const.cidr_any
}

#https://www.terraform.io/docs/providers/aws/r/network_acl_rule.html
resource "aws_network_acl_rule" "public_egress" {
  ###############################################
  count = length(local.public_subnets) > 0 ? 1 : 0

  network_acl_id = aws_network_acl.public[0].id

  egress      = true
  rule_number = module.const.last_rule_number
  rule_action = "allow"
  protocol    = "-1"
  cidr_block  = module.const.cidr_any
}


#https://www.terraform.io/docs/providers/aws/r/network_acl.html
resource "aws_network_acl" "secured" {
  ####################################
  count = length(local.secured_subnets) > 0 ? 1 : 0

  vpc_id     = aws_vpc.this[0].id
  subnet_ids = [for k, v in aws_subnet.secured : v.id]

  tags = merge(local.tags, {
    Name = join(module.const.delimiter, [lookup(
      var.subnets.secured, "name_prefix", null
      ) != null ? var.subnets.secured.name_prefix : lookup(
      var.subnets, "name_prefix", null
      ) != null ? var.subnets.name_prefix : "${local.prefix}${module.const.delimiter}${var.secured_label}",
      module.const.acl_suffix,
    ])
  })
}

#https://www.terraform.io/docs/providers/aws/r/network_acl_rule.html
resource "aws_network_acl_rule" "secured_ingress" {
  #################################################
  count = length(local.secured_subnets) > 0 ? 1 : 0

  network_acl_id = aws_network_acl.secured[0].id

  # egress      = false
  rule_number = module.const.last_rule_number
  rule_action = "allow"
  protocol    = "-1"
  cidr_block  = aws_vpc.this[0].cidr_block
}

#https://www.terraform.io/docs/providers/aws/r/network_acl_rule.html
resource "aws_network_acl_rule" "secured_egress" {
  ################################################
  count = length(local.secured_subnets) > 0 ? 1 : 0

  network_acl_id = aws_network_acl.secured[0].id

  egress      = true
  rule_number = module.const.last_rule_number
  rule_action = "allow"
  protocol    = "-1"
  cidr_block  = aws_vpc.this[0].cidr_block
}