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

#####################
output "lb_subnets" {
  ###################
  value = try(aws_subnet.lb, null)
}

######################
output "k8s_subnets" {
  ####################
  value = try(aws_subnet.k8s, null)
}

#######################
output "misc_subnets" {
  #####################
  value = try(aws_subnet.misc, null)
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
  value = join(" ", [
    local.public_length, local.lb_length, local.k8s_length, local.misc_length, local.secured_length
  ])
}
