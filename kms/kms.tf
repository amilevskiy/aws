#https://www.terraform.io/docs/providers/aws/r/kms_key.html
resource "aws_kms_key" "this" {
  #############################
  count = local.enable

  is_enabled = var.enable

  description                        = var.description
  key_usage                          = var.key_usage
  customer_master_key_spec           = var.customer_master_key_spec
  bypass_policy_lockout_safety_check = var.bypass_policy_lockout_safety_check
  deletion_window_in_days            = var.deletion_window_in_days
  enable_key_rotation                = var.enable_key_rotation
  multi_region                       = var.multi_region

  policy = var.policy #data.aws_iam_policy_document.this[count.index].json

  tags = merge(local.tags, {
    Name = (can(coalesce(var.name_prefix))
      ? "${var.name_prefix}${module.const.kms_suffix}"
    : null)
  })
}

#https://www.terraform.io/docs/providers/aws/r/kms_alias.html
resource "aws_kms_alias" "main" {
  ###############################
  count = can(coalesce(var.name_prefix)) ? local.enable : 0

  name_prefix   = var.name_prefix
  target_key_id = aws_kms_key.this[count.index].id
}

#https://www.terraform.io/docs/providers/aws/r/kms_replica_key.html
resource "aws_kms_replica_key" "this" {
  #####################################
  provider = aws.replica

  count = coalesce(var.multi_region, false) ? local.enable : 0

  primary_key_arn                    = aws_kms_key.this[count.index].arn
  description                        = aws_kms_key.this[count.index].description
  deletion_window_in_days            = aws_kms_key.this[count.index].deletion_window_in_days
  bypass_policy_lockout_safety_check = aws_kms_key.this[count.index].bypass_policy_lockout_safety_check

  policy = var.replica_policy

  tags = merge(local.tags, {
    Name = (can(coalesce(var.name_prefix))
      ? "${var.name_prefix}${var.replica_word}${module.const.delimiter}${module.const.kms_suffix}"
    : null)
  })
}

#https://www.terraform.io/docs/providers/aws/r/kms_alias.html
resource "aws_kms_alias" "replica" {
  ##################################
  provider = aws.replica

  count = coalesce(var.multi_region, false) && can(coalesce(var.name_prefix)) ? local.enable : 0

  name_prefix   = "${var.name_prefix}${var.replica_word}${module.const.delimiter}"
  target_key_id = aws_kms_replica_key.this[count.index].id
}
