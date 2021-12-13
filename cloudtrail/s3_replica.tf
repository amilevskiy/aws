#https://www.terraform.io/docs/configuration/locals.html
locals {
  ######
  replica_bucket = join(module.const.delimiter, [coalesce(var.name, join(module.const.delimiter, concat(
    [module.const.prefix],
    [for k, v in module.const.regions : v.mn_code if v.name == local.region_replica],
    compact([module.const.mn_code, var.default_s3_bucket_suffix, var.name_suffix.replica]),
  )))])
}

#https://www.terraform.io/docs/providers/aws/r/s3_bucket_public_access_block.html
resource "aws_s3_bucket_public_access_block" "replica" {
  ######################################################
  provider = aws.replica

  count = local.enable

  bucket = aws_s3_bucket.replica[count.index].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#https://www.terraform.io/docs/providers/aws/r/s3_bucket.html
resource "aws_s3_bucket" "replica" {
  ##################################
  provider = aws.replica

  count = local.enable

  bucket        = local.replica_bucket
  acl           = module.const.s3_canned_acl_private
  force_destroy = true

  logging {
    target_bucket = aws_s3_bucket.replica_log[count.index].id
    target_prefix = "${local.replica_bucket}/"
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = var.kms_replica_key_arn != null ? "aws:kms" : "AES256"
        kms_master_key_id = var.kms_replica_key_arn
      }
    }
  }

  lifecycle_rule {
    id                                     = module.const.s3_aws_logs_prefix
    prefix                                 = "${module.const.s3_aws_logs_prefix}/"
    enabled                                = true
    abort_incomplete_multipart_upload_days = 1

    expiration {
      days = 3
    }

    noncurrent_version_expiration {
      days = 3
    }
  }

  tags = merge(local.tags, {
    Name = "${local.replica_bucket}${module.const.delimiter}${module.const.s3_suffix}"
  })
}

#https://www.terraform.io/docs/providers/aws/r/s3_bucket_policy.html
resource "aws_s3_bucket_policy" "replica" {
  #########################################
  provider = aws.replica

  count = local.enable

  bucket = aws_s3_bucket.replica[count.index].id
  policy = data.aws_iam_policy_document.s3_replica[count.index].json

  depends_on = [aws_s3_bucket_public_access_block.replica]
}

#https://www.terraform.io/docs/providers/aws/d/iam_policy_document.html
data "aws_iam_policy_document" "s3_replica" {
  ###########################################
  count = local.enable

  statement {
    sid       = "TlsRequestsOnlyPolicy"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = concat(aws_s3_bucket.replica.*.arn, formatlist("%s/*", aws_s3_bucket.replica.*.arn))

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
