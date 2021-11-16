#https://www.terraform.io/docs/configuration/outputs.html
#################
output "enable" {
  ###############
  value = var.enable
}

#############################
output "current_account_id" {
  ###########################
  value = local.current_account_id
}

###########################
output "state_account_id" {
  #########################
  value = var.state_account_id
}

#################
output "config" {
  ###############
  value = {
    region                      = local.region
    profile                     = local.profile,
    role_arn                    = local.role_arn
    bucket                      = local.bucket
    key                         = local.key
    skip_credentials_validation = var.skip_credentials_validation
    skip_region_validation      = var.skip_region_validation
    skip_metadata_api_check     = var.skip_metadata_api_check
  }
}

#####################
output "local_file" {
  ###################
  value = {
    filename             = local.backend_file
    directory_permission = var.backend_directory_permission
    file_permission      = var.backend_file_permission
    content              = join("", data.template_file.this.*.rendered)
  }
}
