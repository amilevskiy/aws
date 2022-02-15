locals {
  main_bucket = join(module.const.delimiter, [coalesce(var.name, join(module.const.delimiter, concat(
    [module.const.prefix],
    [for k, v in module.const.regions : v.mn_code if v.name == local.region_main],
    compact([module.const.mn_code, var.default_s3_bucket_suffix, var.name_suffix.main]),
  )))])

}

#https://www.terraform.io/docs/providers/aws/r/s3_bucket_public_access_block
resource "aws_s3_bucket_public_access_block" "main" {
  ###################################################
  provider = aws.main

  count = local.enable

  bucket = aws_s3_bucket.main[count.index].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#https://www.terraform.io/docs/providers/aws/r/s3_bucket
resource "aws_s3_bucket" "main" {
  ###############################
  provider = aws.main

  count = local.enable

  bucket        = local.main_bucket
  acl           = module.const.s3_canned_acl_private
  force_destroy = true

  logging {
    target_bucket = aws_s3_bucket.main_log[count.index].id
    target_prefix = "${local.account_id}/"
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = var.kms_main_key_arn != null ? "aws:kms" : "AES256"
        kms_master_key_id = var.kms_main_key_arn
      }
    }
  }

  replication_configuration {
    role = aws_iam_role.replica[count.index].arn

    rules {
      id     = "replica_configuration"
      prefix = ""
      status = "Enabled"

      dynamic "source_selection_criteria" {
        for_each = var.kms_main_key_arn != null ? [true] : []
        content {
          dynamic "sse_kms_encrypted_objects" {
            for_each = [source_selection_criteria.value]
            content {
              enabled = sse_kms_encrypted_objects.value
            }
          }
        }
      }

      destination {
        bucket             = aws_s3_bucket.replica[count.index].arn
        storage_class      = "STANDARD_IA"
        replica_kms_key_id = var.kms_replica_key_arn
      }
    }
  }

  lifecycle_rule {
    id                                     = module.const.s3_aws_logs_prefix
    prefix                                 = "${module.const.s3_aws_logs_prefix}/"
    enabled                                = true
    abort_incomplete_multipart_upload_days = 1

    #AbortIncompleteMultipartUpload cannot be specified with Tags
    #tags = {
    #  Name        = "${local.prefix}${module.const.s3_lifecycle_suffix}"
    #  Environment = var.env
    #  Terraform   = "true"
    #}

    expiration {
      days = 3
    }

    noncurrent_version_expiration {
      days = 3
    }
  }

  tags = merge(local.tags, {
    Name = "${local.main_bucket}${module.const.delimiter}${module.const.s3_suffix}"
  })
}

#https://www.terraform.io/docs/providers/aws/r/s3_bucket_policy
resource "aws_s3_bucket_policy" "main" {
  ######################################
  provider = aws.main

  count = local.enable

  bucket = aws_s3_bucket.main[count.index].id
  policy = data.aws_iam_policy_document.main[count.index].json

  depends_on = [aws_s3_bucket_public_access_block.main]
}

#https://www.terraform.io/docs/providers/aws/d/iam_policy_document
data "aws_iam_policy_document" "main" {
  #####################################
  count = local.enable

  #https://docs.aws.amazon.com/config/latest/developerguide/s3-bucket-policy.html#granting-access-in-another-account
  statement {
    sid = "AllowBucketAclCheckAndList"
    actions = [
      "s3:GetBucketAcl",
      "s3:ListBucket",
    ]
    resources = aws_s3_bucket.main.*.arn

    principals {
      type        = "Service"
      identifiers = var.s3_bucket_allowed_services
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = [true]
    }
  }

  statement {
    sid     = "AllowBucketPut"
    actions = ["s3:PutObject"]
    resources = formatlist("%s/%s/%s/*",
      aws_s3_bucket.main[count.index].arn,
      module.const.s3_aws_logs_prefix,
      [local.account_id]
    )

    principals {
      type        = "Service"
      identifiers = var.s3_bucket_allowed_services
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = [true]
    }
  }

  statement {
    sid       = "TlsRequestsOnlyPolicy"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = concat(aws_s3_bucket.main.*.arn, formatlist("%s/*", aws_s3_bucket.main.*.arn))

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = [false]
    }
  }
}
