#################
output "enable" {
  ###############
  value = var.enable
}

##############
output "env" {
  ############
  value = var.env
}

###############
output "name" {
  #############
  value = var.name
}

#############################
output "availability_zones" {
  ###########################
  value = try(var.subnets.availability_zones, null)
}

################################
output "availability_zone_ids" {
  ##############################
  value = try(var.subnets.availability_zone_ids, null)
}

##############
output "vpc" {
  ############
  value = try(var.vpc, null)
}

##################
output "subnets" {
  ################
  value = try(aws_subnet.this, null)
}

#######################
output "route_tables" {
  #####################
  value = try(aws_route_table.this, null)
}

#######################
output "network_acls" {
  #####################
  value = try(aws_network_acl.this, null)
}


# #########################
# output "metadata_value" {
#   #######################
#   value = metadata_value.inbound
# }

# output "enable_subnets" { value = local.enable_subnets }
# output "subnets_keys" { value = local.subnets_keys }
# output "inbound_sliced" { value = local.inbound_sliced }
# output "inbound_expanded" { value = local.inbound_expanded }
# output "inbound_normalized" { value = local.inbound_normalized }
# output "inbound_keys" { value = local.inbound_keys }
output "routes_expanded" { value = local.routes }
