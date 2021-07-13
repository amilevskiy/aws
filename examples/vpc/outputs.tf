##############
output "vpc" {
  ############
  value = module.central.vpc
}

#############################
output "availability_zones" {
  ###########################
  value = module.central.availability_zones
}

################################
output "availability_zone_ids" {
  ##############################
  value = module.central.availability_zone_ids
}

##################
output "subnets" {
  ################
  value = module.central.subnets
}
