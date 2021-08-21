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

####################################
output "network_acl_ingress_rules" {
  ##################################
  value = aws_network_acl_rule.ingress
}

###################################
output "network_acl_egress_rules" {
  #################################
  value = aws_network_acl_rule.egress
}

######################
output "route_table" {
  ####################
  value = try(aws_route_table.this[0], null)
}

# output "routes" { value = local.routes }
