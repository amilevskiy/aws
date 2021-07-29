variable "iam" {
  type = object({
    name = optional(string)

    inline_policy_document = optional(string)

    policy_arns = optional(list(string))
  })

  default = null
}


locals {
  enable_iam = var.enable && var.iam != null ? var.instance != null ? (
    var.instance.iam_instance_profile != null
  ) ? 0 : 1 : 1 : 0

  iam_name = local.enable_iam > 0 && var.iam != null ? var.iam.name != null ? (
    var.iam.name
  ) : local.instance_name : null

  iam_inline_policy_document = local.enable_iam > 0 && var.iam != null ? (
    var.iam.inline_policy_document != null
  ) ? var.iam.inline_policy_document : "" : ""

  iam_policy_arns = local.enable_iam > 0 && var.iam != null ? var.iam.policy_arns != null ? {
    for v in var.iam.policy_arns : replace(v, "/\\//", "") => v
  } : {} : {}
}

#https://www.terraform.io/docs/providers/aws/d/iam_policy_document.html
data "aws_iam_policy_document" "assume" {
  #######################################
  count = local.enable_iam

  statement {
    sid     = "Ec2TrustRelationshipPolicy"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

#https://www.terraform.io/docs/providers/aws/r/iam_role.html
resource "aws_iam_role" "this" {
  ##############################
  count = local.enable_iam

  name_prefix = "${substr(join(module.const.delimiter, [
    "iamRole",
    local.iam_name,
  ]), 0, 32-length(module.const.delimiter))}${module.const.delimiter}"

  description = "Allows access to AWS resources for ${local.instance_name}-instance"

  assume_role_policy = data.aws_iam_policy_document.assume[0].json

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${local.iam_name}${module.const.delimiter}${module.const.iam_role_suffix}"
  }
}

#как-то надо сделать условную генерацию policy только для t2|t3|t3a-инстансов
#https://www.terraform.io/docs/providers/aws/r/iam_role_policy.html
resource "aws_iam_role_policy" "this" {
  #####################################
  count = local.enable_iam

  name_prefix = "${join(module.const.delimiter, [
    "iamInlinePolicy",
    local.iam_name,
  ])}${module.const.delimiter}"

  role = aws_iam_role.this[0].name

  policy = coalesce(local.iam_inline_policy_document, data.aws_iam_policy_document.inline[0].json)

  lifecycle {
    create_before_destroy = true
  }
}

#https://www.terraform.io/docs/providers/aws/d/iam_policy_document.html
data "aws_iam_policy_document" "inline" {
  #######################################
  count = local.enable_iam > 0 && local.iam_inline_policy_document == "" ? 1 : 0

  statement {
    sid       = "ModifyInstanceCreditSpecification"
    actions   = ["ec2:ModifyInstanceCreditSpecification"]
    resources = ["*"]
  }
}

#https://www.terraform.io/docs/providers/aws/r/iam_instance_profile.html
resource "aws_iam_instance_profile" "this" {
  ##########################################
  count = local.enable_iam

  name_prefix = "${substr(join(module.const.delimiter, [
    "iamProfile",
    local.iam_name,
  ]), 0, 64-length(module.const.delimiter))}${module.const.delimiter}"

  role = aws_iam_role.this[0].name

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${local.iam_name}${module.const.delimiter}${module.const.iam_instance_profile_suffix}"
  }
}

#https://www.terraform.io/docs/providers/aws/r/iam_role_policy_attachment.html
resource "aws_iam_role_policy_attachment" "this" {
  ################################################
  for_each = local.iam_policy_arns

  role       = aws_iam_role.this[0].name
  policy_arn = each.value
}
