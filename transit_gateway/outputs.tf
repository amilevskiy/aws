#https://www.terraform.io/docs/configuration/outputs
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

##########################
output "transit_gateway" {
  ########################
  value = try(aws_ec2_transit_gateway.this[0], null)
}

#########################
output "resource_share" {
  #######################
  value = try(aws_ram_resource_share.this[0], null)
}

###############################
output "resource_association" {
  #############################
  value = try(aws_ram_resource_association.this[0], null)
}

################################
output "principal_association" {
  ##############################
  value = aws_ram_principal_association.this
}

###########################################
output "resource_share_accepter_template" {
  #########################################
  value = data.template_file.this
}
