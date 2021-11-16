#https://www.terraform.io/docs/providers/aws/d/caller_identity.html
data "aws_caller_identity" "this" {
  #################################
  count = var.current_account_id == "" ? local.enable : 0
}

#https://www.terraform.io/docs/language/state/remote-state-data.html
data "terraform_remote_state" "this" {
  ####################################
  count = local.enable

  backend = "s3"

  config = {
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

#https://www.terraform.io/docs/providers/template/d/file.html
data "template_file" "this" {
  ###########################
  count = local.enable

  vars = {
    account_id = local.current_account_id
    key_suffix = local.key_suffix
  }

  template = data.terraform_remote_state.this[count.index].outputs.backend_template
}

#https://www.terraform.io/docs/configuration/locals.html
locals {
  ######

  enable = var.enable ? 1 : 0

  current_account_id = try(
    data.aws_caller_identity.this[0].account_id,
    var.current_account_id
  )

  region = coalesce(var.region, module.const.regions.primary.name)

  profile = coalesce(var.profile, module.const.awscli_terraform_profile)

  role_arn = coalesce(var.role_arn, format(module.const.fmt_backend_role_arn,
    var.state_account_id, local.current_account_id)
  )

  bucket = coalesce(var.bucket, join(module.const.delimiter, [
    module.const.prefix,
    module.const.regions.primary.mn_code,
    module.const.mn_code,
    "networking"
  ]))

  key = coalesce(var.key, join(module.const.path_separator, [
    module.const.tfstate,
    var.state_account_id,
    module.const.regions.primary.id,
    join(module.const.delimiter, [
      "010",
      module.const.tfstate,
    ])
  ]))

  key_suffix = coalesce(var.key_suffix,
    replace(abspath(path.root), "/.*\\/([0-9]{12}\\/)/", "$1")
  )

  backend_file = coalesce(var.backend_file, join(module.const.path_separator, [
    path.root,
    module.const.backend_tf,
  ]))
}
