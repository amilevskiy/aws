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

################################
output "leader_resource_share" {
  ##############################
  value = try(aws_ram_resource_share.leader, null)
}

######################################
output "leader_resource_association" {
  ####################################
  value = try(aws_ram_resource_association.leader, null)
}

#######################################
output "leader_principal_association" {
  #####################################
  value = try(aws_ram_principal_association.leader, null)
}

###########################################
output "follower_resource_share_accepter" {
  #########################################
  value = try(aws_ram_resource_share_accepter.follower, null)
}
