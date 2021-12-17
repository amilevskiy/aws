#################
output "enable" {
  ###############
  value = var.enable
}

###########################
output "replication_role" {
  #########################
  value = try(aws_iam_role.replica[0], null)
}

#############################
output "replication_policy" {
  ###########################
  value = try(aws_iam_policy.replica[0], null)
}

#########################
output "s3_bucket_main" {
  #######################
  value = try(aws_s3_bucket.main[0], null)
}

#############################
output "s3_bucket_main_log" {
  ###########################
  value = try(aws_s3_bucket.main_log[0], null)
}

############################
output "s3_bucket_replica" {
  ##########################
  value = try(aws_s3_bucket_policy.replica[0], null)
}

################################
output "s3_bucket_replica_log" {
  ##############################
  value = try(aws_s3_bucket_policy.replica_log[0], null)
}

#######################################
output "s3_bucket_replica_iam_policy" {
  #####################################
  value = try(data.aws_iam_policy_document.s3_replica[0].json, null)
}
