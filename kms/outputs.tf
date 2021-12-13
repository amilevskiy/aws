#################
output "enable" {
  ###############
  value = var.enable
}

##################
output "kms_key" {
  ################
  value = try(aws_kms_key.this[0], null)
}

####################
output "kms_alias" {
  ##################
  value = try(aws_kms_alias.main[0], null)
}

##########################
output "kms_replica_key" {
  ########################
  value = try(aws_kms_replica_key.this[0], null)
}

############################
output "kms_replica_alias" {
  ##########################
  value = try(aws_kms_alias.replica[0], null)
}
