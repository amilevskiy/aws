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

###################
output "instance" {
  #################
  value = try(aws_instance.this[0], aws_spot_instance_request.this[0], null)
}

###################
output "iam_role" {
  #################
  value = try(aws_iam_role.this[0], null)
}

##########################
output "iam_role_policy" {
  ########################
  value = try(aws_iam_role_policy.this[0], null)
}

###################
output "key_pair" {
  #################
  value = try(aws_key_pair.this[0], null)
}
