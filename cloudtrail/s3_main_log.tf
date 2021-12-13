locals {
  ######
  main_log_bucket = join(module.const.delimiter, [coalesce(var.name, join(module.const.delimiter, concat(
    [module.const.prefix],
    [for k, v in module.const.regions : v.mn_code if v.name == local.region_main],
    compact([module.const.mn_code, var.default_s3_bucket_suffix, var.name_suffix.main-log]),
  )))])
}

#https://www.terraform.io/docs/providers/aws/r/s3_bucket_public_access_block.html
resource "aws_s3_bucket_public_access_block" "main_log" {
  #######################################################
  provider = aws.main

  count = local.enable

  bucket = aws_s3_bucket.main_log[count.index].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#https://www.terraform.io/docs/providers/aws/r/s3_bucket.html
resource "aws_s3_bucket" "main_log" {
  ###################################
  provider = aws.main

  count = local.enable

  bucket = local.main_log_bucket

  acl           = "log-delivery-write"
  force_destroy = true

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        #Encryption using AWS-KMS (SSE-KMS) is not supported
        #https://aws.amazon.com/premiumsupport/knowledge-center/s3-server-access-log-not-delivered
        #https://docs.aws.amazon.com/AmazonS3/latest/dev/ServerLogs.html#server-access-logging-overview
        sse_algorithm = "AES256"
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
    id                                     = local.main_log_bucket
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
    Name = "${local.main_log_bucket}${module.const.delimiter}${module.const.s3_suffix}"
  })
}

#https://www.terraform.io/docs/providers/aws/r/s3_bucket_policy.html
resource "aws_s3_bucket_policy" "main_log" {
  ##########################################
  provider = aws.main

  count = local.enable

  bucket = aws_s3_bucket.main_log[count.index].id
  policy = data.aws_iam_policy_document.main_log[count.index].json

  depends_on = [aws_s3_bucket_public_access_block.main_log]
}

#https://www.terraform.io/docs/providers/aws/d/iam_policy_document.html
data "aws_iam_policy_document" "main_log" {
  #########################################
  count = local.enable

  statement {
    sid       = "AllowBucketAclCheck"
    actions   = ["s3:GetBucketAcl"]
    resources = aws_s3_bucket.main_log.*.arn

    principals {
      type        = "AWS"
      identifiers = formatlist("arn:aws:iam::%s:root", local.account_id)
    }
  }

  statement {
    sid       = "AllowBucketPut"
    actions   = ["s3:PutObject"]
    resources = formatlist("%s/%s/*", aws_s3_bucket.main_log.*.arn, local.account_id)

    principals {
      type        = "AWS"
      identifiers = formatlist("arn:aws:iam::%s:root", local.account_id)
    }
  }

  statement {
    sid       = "TlsRequestsOnlyPolicy"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = concat(aws_s3_bucket.main_log.*.arn, formatlist("%s/*", aws_s3_bucket.main_log.*.arn))

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
