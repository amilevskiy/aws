#################
output "enable" {
  ###############
  value       = var.enable
  description = "var.enable passthrough"
}

##############
output "env" {
  ############
  value       = var.env
  description = "var.env passthrough"
}

###############
output "name" {
  #############
  value       = var.name
  description = "var.name passthrough"
}

#############################
output "availability_zones" {
  ###########################
  value       = try(var.subnets.availability_zones, null)
  description = "The list of used availability zones"
}

################################
output "availability_zone_ids" {
  ##############################
  value       = try(var.subnets.availability_zone_ids, null)
  description = "The list of used availability zone ids"
}

##############
output "vpc" {
  ############
  value       = try(aws_vpc.this[0], null)
  description = "The \"aws_vpc\" object"
}

##################
output "subnets" {
  ################
  value       = aws_subnet.this
  description = "The map of \"aws_subnet\" objects"
}

#######################
output "route_tables" {
  #####################
  value       = aws_route_table.this
  description = "The map of \"aws_route_table\" objects"
}

#######################
output "network_acls" {
  #####################
  value       = aws_network_acl.this
  description = "The map of \"aws_route_table\" objects"
}

#########################################
output "transit_gateway_vpc_attachment" {
  #######################################
  value       = aws_ec2_transit_gateway_vpc_attachment.this
  description = "The map of \"aws_ec2_transit_gateway_vpc_attachment\" objects"
}

#######################
output "vpc_endpoint" {
  #####################
  value       = aws_vpc_endpoint.this
  description = "The map of \"aws_vpc_endpoint\" objects"
}

#######################################
output "vpc_endpoint_security_groups" {
  #####################################
  value       = aws_security_group.vpce
  description = "The map of \"aws_security_group\" objects that applied to appropriate \"aws_vpc_endpoint\" objects"
}

######################
output "nat_gateway" {
  ####################
  value       = try(aws_nat_gateway.this[0], null)
  description = "The \"aws_nat_gateway\" object"
}

##########################
output "security_groups" {
  ########################
  value       = aws_security_group.this
  description = "The map of \"aws_security_group\" objects"
}
