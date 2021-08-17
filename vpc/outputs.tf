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
  value = try(aws_vpc.this[0], null)
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

#########################################
output "transit_gateway_vpc_attachment" {
  #######################################
  value = try(aws_ec2_transit_gateway_vpc_attachment.this, null)
}

#######################
output "vpc_endpoint" {
  #####################
  value = try(aws_vpc_endpoint.this, null)
}

#######################################
output "vpc_endpoint_security_groups" {
  #####################################
  value = try(aws_security_group.this, null)
}

#############################
output "enable_data_region" {
  ###########################
  value = local.enable_data_region
}
