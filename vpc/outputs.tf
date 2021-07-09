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

##############
output "vpc" {
  ############
  value = try(aws_vpc.this[0], null)
}

#########################
output "public_subnets" {
  #######################
  value = try(aws_subnet.public, null)
}

##########################
output "private_subnets" {
  ########################
  value = try(aws_subnet.private, null)
}

##########################
output "secured_subnets" {
  ########################
  value = try(aws_subnet.secured, null)
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

#################
output "length" {
  ###############
  value = join(" ", [local.public_length, local.private_length, local.secured_length])
}
