#https://www.terraform.io/docs/providers/aws/d/caller_identity
data "aws_caller_identity" "this" {
  #################################
  count = local.is_path_match ? 0 : local.enable
}

#https://www.terraform.io/docs/providers/aws/d/region
data "aws_region" "this" {
  ########################
  count = local.is_path_match ? 0 : local.enable
}

#https://www.terraform.io/docs/language/state/remote-state-data
data "terraform_remote_state" "this" {
  ####################################
  count = local.enable

  backend = "s3"

  config = local.config
}

#https://www.terraform.io/docs/providers/template/d/file
data "template_file" "this" {
  ###########################
  count = local.enable

  vars = {
    key_suffix = local.key_suffix
  }

  template = data.terraform_remote_state.this[count.index].outputs.backend_template
}

#https://www.terraform.io/docs/configuration/locals
locals {
  ######

  enable = var.enable && !fileexists(local.backend_filename) ? 1 : 0

  region = coalesce(var.region, module.const.regions.primary.name)

  profile = coalesce(var.profile, module.const.awscli_terraform_profile)

  role_arn = coalesce(var.role_arn,
    "arn:aws:iam::${var.backend_account_id}:role/${module.const.backend_role_name}",
  )

  bucket = coalesce(var.bucket, join(module.const.delimiter, [
    module.const.prefix,
    module.const.regions.primary.mn_code,
    module.const.mn_code,
    var.default_bucket_suffix
  ]))

  key = coalesce(var.key, join(module.const.path_separator, [
    module.const.tfstate,
    var.backend_account_id,
    module.const.regions.primary.id,
    join(module.const.delimiter, [
      var.default_directory_prefix,
      module.const.tfstate,
    ])
  ]))

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

  is_path_match = can(regex("\\/[0-9]{12}\\/", abspath(path.root)))

  key_suffix = coalesce(var.key_suffix, (local.is_path_match
    ? replace(abspath(path.root), "/.*\\/([0-9]{12}\\/)/", "$1")
    : join(module.const.path_separator, compact(concat(
      data.aws_caller_identity.this.*.account_id,
      [for v in data.aws_region.this : replace(v.name, "/^([^-]+)-([^-]).+-([^-]+)$/", "$1$2$3")],
      [replace(abspath(path.root), "/.*\\//", "")],
  )))))

  backend_filename = coalesce(var.backend_filename, module.const.backend_tf)
}
