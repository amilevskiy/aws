#################
output "enable" {
  ###############
  value = var.enable
}

##################
output "subnets" {
  ################
  value = aws_subnet.this
}

#######################
output "network_acls" {
  #####################
  value = aws_network_acl.this
}

######################
output "route_table" {
  ####################
  value = try(aws_route_table.this[0], null)
}

##########################
output "security_groups" {
  ########################
  value = aws_security_group.this
}

# output "inbound_sg_rules" { value = local.inbound_sg_rules }
