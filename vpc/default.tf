# формально: чистим и пусть висят

#https://www.terraform.io/docs/providers/aws/r/default_vpc_dhcp_options.html
resource "aws_default_vpc_dhcp_options" "this" {
  ##############################################
  count = var.enable && var.manage_default_vpc_dhcp_options ? 1 : 0

  netbios_node_type = 2

  tags = {
    Name = join(module.const.delimiter, [
      module.const.prefix,
      var.default_label,
      module.const.dhcp_options_suffix,
    ])
  }
}

#https://www.terraform.io/docs/providers/aws/r/default_route_table.html
resource "aws_default_route_table" "this" {
  #########################################
  count = local.enable_vpc

  default_route_table_id = aws_vpc.this[0].default_route_table_id

  #must!
  route = []

  tags = {
    Name = join(module.const.delimiter, [
      local.prefix,
      var.default_label,
      module.const.rtb_suffix,
    ])
  }
}

#https://www.terraform.io/docs/providers/aws/r/default_network_acl.html
resource "aws_default_network_acl" "this" {
  #########################################
  count = local.enable_vpc

  default_network_acl_id = aws_vpc.this[0].default_network_acl_id

  ingress {
    rule_no    = 1
    action     = "deny"
    protocol   = -1
    cidr_block = module.const.cidr_any
    from_port  = 0
    to_port    = 0
  }

  egress {
    rule_no    = 1
    action     = "deny"
    protocol   = -1
    cidr_block = module.const.cidr_any
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = join(module.const.delimiter, [
      local.prefix,
      var.default_label,
      module.const.acl_suffix,
    ])
  }

  lifecycle {
    ignore_changes = [subnet_ids]
  }
}

#https://www.terraform.io/docs/providers/aws/r/default_security_group.html
resource "aws_default_security_group" "this" {
  ############################################
  count = local.enable_vpc

  vpc_id = aws_vpc.this[0].id

  tags = {
    Name = join(module.const.delimiter, [
      local.prefix,
      var.default_label,
      module.const.sg_suffix,
    ])
  }
}
