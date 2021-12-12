#https://www.terraform.io/docs/providers/aws/r/kms_key.html
resource "aws_kms_key" "this" {
  #############################
  count = local.enable

  description              = var.description
  key_usage                = var.key_usage
  customer_master_key_spec = var.customer_master_key_spec

  policy = var.policy #data.aws_iam_policy_document.this[count.index].json

  bypass_policy_lockout_safety_check = var.bypass_policy_lockout_safety_check
  deletion_window_in_days            = var.deletion_window_in_days

  is_enabled = var.enable

  enable_key_rotation = var.enable_key_rotation
  multi_region        = var.multi_region

  tags = merge(local.tags, {
    #Name = "${local.prefix}${module.const.kms_suffix}"
  })
}

#https://www.terraform.io/docs/providers/aws/d/iam_policy_document.html
# data "aws_iam_policy_document" "this" {
#   #####################################
#   count = local.enable

#   dynamic "statement" {
#     for_each = var.policy != null ? var.policy : {}
#     content {
#       sid       = statement.key
#       effect    = statement.value.effect != null ? statement.value.effect : null
#       actions   = statement.value.actions != null ? statement.value.actions : ["*"]
#       resources = statement.value.resources != null ? statement.value.resources : ["*"]

#       dynamic "principals" {
#         for_each = statement.value.principals != null ? statement.value.principals : {}
#         content {
#           type        = principals.key
#           identifiers = principals.value
#         }
#       }

#       dynamic "condition" {
#         for_each = statement.value.condition != null ? statement.value.condition : {}
#         content {
#           test     = condition.key
#           variable = condition.value.variable
#           values   = condition.value.values
#         }
#       }
#     }
#   }

#   statement {
#     sid       = "AllowIamUser"
#     actions   = ["kms:*"]
#     resources = ["*"]

#     principals {
#       type        = "AWS"
#       identifiers = ["arn:aws:iam::${local.account_id}:root"]
#     }
#   }

#   statement {
#     sid       = "AllowCloudTrailEncrypt"
#     actions   = ["kms:GenerateDataKey*"]
#     resources = ["*"]

#     principals {
#       type        = "Service"
#       identifiers = ["cloudtrail.amazonaws.com"]
#     }

#     condition {
#       test     = "StringLike"
#       variable = "kms:EncryptionContext:aws:cloudtrail:arn"
#       values   = ["arn:aws:cloudtrail:*:${local.account_id}:trail/*"]
#     }
#   }

#   statement {
#     sid = "AllowCloudWatchLogsAnyGroup"

#     actions = [
#       "kms:Encrypt*",
#       "kms:Decrypt*",
#       "kms:ReEncrypt*",
#       "kms:GenerateDataKey*",
#       "kms:Describe*"
#     ]

#     resources = ["*"]

#     principals {
#       type        = "Service"
#       identifiers = ["logs.${local.region}.amazonaws.com"]
#     }

#     condition {
#       test     = "ArnEquals"
#       variable = "kms:EncryptionContext:aws:logs:arn"
#       values   = ["arn:aws:logs:${local.region}:${local.account_id}:*"]
#     }
#   }

#   statement {
#     sid = "AllowVpcFlowLogs"

#     actions = [
#       "kms:Encrypt*",
#       "kms:Decrypt*",
#       "kms:ReEncrypt*",
#       "kms:GenerateDataKey*",
#       "kms:Describe*"
#     ]

#     resources = ["*"]

#     principals {
#       type        = "Service"
#       identifiers = ["delivery.logs.amazonaws.com"]
#     }
#   }
# }
