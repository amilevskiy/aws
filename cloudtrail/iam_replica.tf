locals {
  role_replica_name_prefix = join(module.const.delimiter, [
    "S3ReplicaRole", local.region_main_short, local.region_replica_short, ""
  ])

  policy_replica_name_prefix = join(module.const.delimiter, [
    "iamPolicyReplica", local.region_main_short, local.region_replica_short, ""
  ])
}

#https://www.terraform.io/docs/providers/aws/r/iam_role
resource "aws_iam_role" "replica" {
  #################################
  provider = aws.main

  count = local.enable

  name_prefix = local.role_replica_name_prefix
  description = "Role required for S3 cross-region replication ${local.region_main}-${local.region_replica}"

  assume_role_policy = jsonencode({
    Version = module.const.policy_version
    Statement = [{
      Sid    = "S3ReplicaAssumePolicy"
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "s3.amazonaws.com"
      }
  }] })

  permissions_boundary = var.replica_role_permissions_boundary

  tags = merge(local.tags, {
    Name = "${local.role_replica_name_prefix}${module.const.iam_role_suffix}"
  })
}

#https://www.terraform.io/docs/providers/aws/r/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "replica" {
  ###################################################
  provider = aws.main

  count = local.enable

  role       = aws_iam_role.replica[count.index].name
  policy_arn = aws_iam_policy.replica[count.index].arn
}

#https://www.terraform.io/docs/providers/aws/r/iam_policy
resource "aws_iam_policy" "replica" {
  ###################################
  provider = aws.main

  count = local.enable

  name_prefix = local.policy_replica_name_prefix
  description = "Policy allows S3 cross-region replication ${local.region_main}-${local.region_replica}"

  policy = data.aws_iam_policy_document.replica[count.index].json

  tags = merge(local.tags, {
    Name = "${local.policy_replica_name_prefix}${module.const.iam_policy_suffix}"
  })
}

#Перепроверил соответствие всех API к resource... Не понимаю, отчего предупреждение:
#This policy defines some actions, resources, or conditions that do not provide permissions. To grant access, policies must have an action that has an applicable resource or condition.
#И напротив KMS уточняет: One or more conditions do not have an applicable action.
#https://docs.aws.amazon.com/AmazonS3/latest/dev/setting-repl-config-perm-overview.html
#https://www.terraform.io/docs/providers/aws/d/iam_policy_document
data "aws_iam_policy_document" "replica" {
  ########################################
  count = local.enable

#https://docs.aws.amazon.com/AmazonS3/latest/dev/list_amazons3
  statement {
    sid = "AllowSourceGetConfiguration"

    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket"
    ]

    resources = aws_s3_bucket.main.*.arn
  }

  statement {
    sid = "AllowSourceGetObjectInfo"

    actions = [
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionTagging"
    ]

    resources = formatlist("%s/*", aws_s3_bucket.main.*.arn)
  }

  statement {
    sid = "AllowDestinationReplicate"

    actions = [
      "s3:ReplicateDelete",
      "s3:ReplicateObject",
      "s3:ReplicateTags"
    ]

    resources = formatlist("%s/*", aws_s3_bucket.replica.*.arn)
  }

#https://docs.aws.amazon.com/AmazonS3/latest/dev/replication-config-for-kms-objects
  dynamic "statement" {
    for_each = var.kms_main_key_arn != null ? [var.kms_main_key_arn] : []
    content {
      sid       = "AllowSourceDecrypt"
      actions   = ["kms:Decrypt"]
      resources = [statement.value]

      condition {
        test     = "StringEquals"
        variable = "kms:ViaService"
        values   = ["s3.${local.region_main}.amazonaws.com"]
      }

      #Policy Visual Editor указывает сюда с сообщением: There are no actions in your policy that support this condition key.
      condition {
        test     = "StringLike"
        variable = "kms:EncryptionContext:aws:s3:arn"
        values   = formatlist("%s/*", aws_s3_bucket.main.*.arn)
      }
    }
  }


  dynamic "statement" {
    for_each = var.kms_replica_key_arn != null ? [var.kms_replica_key_arn] : []
    content {
      sid = "AllowDestinationEncrypt"

      actions = [
        "kms:Encrypt",
        "kms:GenerateDataKey"
      ]

      resources = [statement.value]

      condition {
        test     = "StringEquals"
        variable = "kms:ViaService"
        values   = ["s3.${local.region_replica}.amazonaws.com"]
      }

      #Policy Visual Editor указывает и сюда с сообщением: There are no actions in your policy that support this condition key.
      condition {
        test     = "StringLike"
        variable = "kms:EncryptionContext:aws:s3:arn"
        values   = formatlist("%s/*", aws_s3_bucket.replica.*.arn)
      }
    }
  }
}
