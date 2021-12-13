locals {
  role_replica_name_prefix = join(module.const.delimiter, [
    "S3ReplicaRole", local.region_main_short, local.region_replica_short, ""
  ])
}

#https://www.terraform.io/docs/providers/aws/r/iam_role.html
resource "aws_iam_role" "replica" {
  #################################
  provider = aws.main

  count = local.enable

  name_prefix = local.role_replica_name_prefix
  description = "Role required for S3 cross-region replication ${local.region_main}-${local.region_replica}"

  assume_role_policy = jsonencode({
    Sid    = "S3ReplicaAssumePolicy"
    Effect = "Allow"
    Action = "sts:AssumeRole"
    Principal = {
      Service = "s3.amazonaws.com"
    }
  })

  permissions_boundary = var.replica_role_permissions_boundary

  tags = merge(local.tags, {
    Name = "${local.role_replica_name_prefix}${module.const.iam_role_suffix}"
  })
}

#https://www.terraform.io/docs/providers/aws/r/iam_policy.html
resource "aws_iam_policy" "replica" {
  ###################################
  provider = aws.main

  count = local.enable

  name        = "iamPolicyReplica"
  description = "Policy allows S3 cross-region replication"

  # policy = data.aws_iam_policy_document.replica[count.index].json
  #Перепроверил соответствие всех API к resource... Не понимаю, отчего предупреждение:
  #This policy defines some actions, resources, or conditions that do not provide permissions. To grant access, policies must have an action that has an applicable resource or condition.
  #И напротив KMS уточняет: One or more conditions do not have an applicable action.
  #https://docs.aws.amazon.com/AmazonS3/latest/dev/setting-repl-config-perm-overview.html
  #https://www.terraform.io/docs/providers/aws/d/iam_policy_document.html
  policy = jsonencode(merge({
    Version = module.const.policy_version
    #https://docs.aws.amazon.com/AmazonS3/latest/dev/list_amazons3.html
    Statement = [
      {
        Sid    = "AllowSourceGetConfiguration"
        Effect = "Allow"
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.main.*.arn
      },
      {
        Sid    = "AllowSourceGetObjectInfo"
        Effect = "Allow"
        Action = [
          "s3:GetObjectVersion",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionTagging"
        ]
        Resource = formatlist("%s/*", aws_s3_bucket.main.*.arn)
      },
      {
        Sid    = "AllowDestinationReplicate"
        Effect = "Allow"
        Action = [
          "s3:ReplicateDelete",
          "s3:ReplicateObject",
          "s3:ReplicateTags"
        ]
        Resource = formatlist("%s/*", aws_s3_bucket.replica.*.arn)
      }
  ] }, local.replica_kms_main_policy, local.replica_kms_replica_policy))
}

locals {
  #https://docs.aws.amazon.com/AmazonS3/latest/dev/replication-config-for-kms-objects.html
  replica_kms_main_policy = var.kms_main_key_arn != null && false ? tomap({
    Sid      = "AllowSourceDecrypt"
    Effect   = "Allow"
    Action   = "kms:Decrypt"
    Resource = var.kms_main_key_arn
    Condition = tomap({
      StringEquals = tomap({
        "kms:ViaService" = ["s3.${local.region_main}.amazonaws.com"]
      })
      StringLike = tomap({
        "kms:EncryptionContext:aws:s3:arn" = formatlist("%s/*", aws_s3_bucket.main.*.arn)
      })
    })
  }) : tomap({})

  replica_kms_replica_policy = var.kms_replica_key_arn != null && false ? tomap({
    Sid    = "AllowDestinationEncrypt"
    Effect = "Allow"
    Action = [
      "kms:Encrypt",
      "kms:GenerateDataKey"
    ]
    Resource = [var.kms_replica_key_arn]
    Condition = {
      StringEquals = {
        "kms:ViaService" = ["s3.${local.region_replica}.amazonaws.com"]
      }
      StringLike = {
        "kms:EncryptionContext:aws:s3:arn" = formatlist("%s/*", aws_s3_bucket.replica.*.arn)
      }
    }
  }) : {}
}

# data "aws_iam_policy_document" "replica" {
#   ########################################
#   count = local.enable

#   dynamic "statement" {
#     for_each = merge(local.replica_policy, local.replica_kms_policy)
#     content {
#       sid       = statement.key
#       actions   = statement.value.actions
#       resources = statement.value.resources
#     }
#   }


#https://docs.aws.amazon.com/AmazonS3/latest/dev/list_amazons3.html
# statement {
#   sid = "AllowSourceGetConfiguration"

#   actions = [
#     "s3:GetReplicationConfiguration",
#     "s3:ListBucket"
#   ]

#   resources = aws_s3_bucket.main.*.arn
# }

# statement {
#   sid = "AllowSourceGetObjectInfo"

#   actions = [
#     "s3:GetObjectVersion",
#     "s3:GetObjectVersionAcl",
#     "s3:GetObjectVersionForReplication",
#     "s3:GetObjectVersionTagging"
#   ]

#   resources = formatlist("%s/*", aws_s3_bucket.main.*.arn)
# }

# statement {
#   sid = "AllowDestinationReplicate"

#   actions = [
#     "s3:ReplicateDelete",
#     "s3:ReplicateObject",
#     "s3:ReplicateTags"
#   ]

#   resources = formatlist("%s/*", aws_s3_bucket.replica.*.arn)
# }



#https://docs.aws.amazon.com/AmazonS3/latest/dev/replication-config-for-kms-objects.html
# statement {
#   sid       = "AllowSourceDecrypt"
#   actions   = ["kms:Decrypt"]
#   resources = aws_kms_key.main.*.arn

#   condition {
#     test     = "StringEquals"
#     variable = "kms:ViaService"
#     values   = ["s3.${var.aws_region}.amazonaws.com"]
#   }

#   #Policy Visual Editor указывает сюда с сообщением: There are no actions in your policy that support this condition key.
#   condition {
#     test     = "StringLike"
#     variable = "kms:EncryptionContext:aws:s3:arn"
#     values   = formatlist("%s/*", aws_s3_bucket.main.*.arn)
#   }
# }

# statement {
#   sid = "AllowDestinationEncrypt"

#   actions = [
#     "kms:Encrypt",
#     "kms:GenerateDataKey"
#   ]

#   resources = aws_kms_key.replica.*.arn

#   condition {
#     test     = "StringEquals"
#     variable = "kms:ViaService"
#     values   = ["s3.${var.aws_replica_region}.amazonaws.com"]
#   }

#   #Policy Visual Editor указывает и сюда с сообщением: There are no actions in your policy that support this condition key.
#   condition {
#     test     = "StringLike"
#     variable = "kms:EncryptionContext:aws:s3:arn"
#     values   = formatlist("%s/*", aws_s3_bucket.replica.*.arn)
#   }
# }
# }

#https://www.terraform.io/docs/providers/aws/r/iam_role_policy_attachment.html
resource "aws_iam_role_policy_attachment" "replica" {
  ###################################################
  provider = aws.main

  count = local.enable

  role       = aws_iam_role.replica[count.index].name
  policy_arn = aws_iam_policy.replica[count.index].arn
}
