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
