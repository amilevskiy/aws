#https://www.terraform.io/docs/configuration/outputs.html
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
