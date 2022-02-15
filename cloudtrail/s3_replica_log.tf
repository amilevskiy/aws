#https://www.terraform.io/docs/configuration/locals
locals {
  ######
  replica_log_bucket = join(module.const.delimiter, [coalesce(var.name, join(module.const.delimiter, concat(
    [module.const.prefix],
    [for k, v in module.const.regions : v.mn_code if v.name == local.region_replica],
    compact([module.const.mn_code, var.default_s3_bucket_suffix, var.name_suffix.replica-log]),
  )))])
}

#https://www.terraform.io/docs/providers/aws/r/s3_bucket_public_access_block
resource "aws_s3_bucket_public_access_block" "replica_log" {
  ##########################################################
  provider = aws.replica

  count = local.enable_replica

  bucket = aws_s3_bucket.replica_log[count.index].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#https://www.terraform.io/docs/providers/aws/r/s3_bucket
resource "aws_s3_bucket" "replica_log" {
  ######################################
  provider = aws.replica

  count = local.enable_replica

  bucket = local.replica_log_bucket

  acl           = "log-delivery-write"
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    id                                     = local.replica_log_bucket
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
    Name = "${local.replica_log_bucket}${module.const.delimiter}${module.const.s3_suffix}"
  })
}

#https://www.terraform.io/docs/providers/aws/r/s3_bucket_policy
resource "aws_s3_bucket_policy" "replica_log" {
  #############################################
  provider = aws.replica

  count = local.enable_replica

  bucket = aws_s3_bucket.replica_log[count.index].id
  policy = data.aws_iam_policy_document.replica_log[count.index].json

  depends_on = [aws_s3_bucket_public_access_block.replica_log]
}

#https://www.terraform.io/docs/providers/aws/d/iam_policy_document
data "aws_iam_policy_document" "replica_log" {
  ############################################
  count = local.enable_replica

  statement {
    sid       = "AllowBucketAclCheck"
    actions   = ["s3:GetBucketAcl"]
    resources = aws_s3_bucket.replica_log.*.arn

    principals {
      type        = "AWS"
      identifiers = formatlist("arn:aws:iam::%s:root", local.account_id)
    }
  }

  statement {
    sid       = "AllowBucketPut"
    actions   = ["s3:PutObject"]
    resources = formatlist("%s/%s/*", aws_s3_bucket.replica_log.*.arn, local.account_id)

    principals {
      type        = "AWS"
      identifiers = formatlist("arn:aws:iam::%s:root", local.account_id)
    }
  }

  statement {
    sid       = "TlsRequestsOnlyPolicy"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = concat(aws_s3_bucket.replica_log.*.arn, formatlist("%s/*", aws_s3_bucket.replica_log.*.arn))

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
