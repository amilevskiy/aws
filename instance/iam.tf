locals {
  enable_iam = var.enable && var.instance != null ? lookup(
    var.instance, "iam_instance_profile", null
  ) != null ? var.instance.iam_instance_profile != "" ? 0 : 1 : 1 : 0

  iam_policy_arns = local.enable_iam > 0 ? {
    for v in var.iam_policy_arns : replace(v, "/\\//", "") => v
  } : {}
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

  name_prefix = "${join(module.const.delimiter, [
    "iamRole",
    local.instance_name,
  ])}${module.const.delimiter}"

  description = "Allows access to AWS resources for ${local.instance_name}-instance"

  assume_role_policy = data.aws_iam_policy_document.assume[0].json

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${local.instance_name}${module.const.delimiter}${module.const.iam_role_suffix}"
  }
}

#как-то надо сделать условную генерацию policy только для t2|t3|t3a-инстансов
#https://www.terraform.io/docs/providers/aws/r/iam_role_policy.html
resource "aws_iam_role_policy" "this" {
  #####################################
  count = local.enable_iam

  name_prefix = "${join(module.const.delimiter, [
    "iamInlinePolicy",
    local.instance_name,
  ])}${module.const.delimiter}"

  role = aws_iam_role.this[0].name

  policy = coalesce(var.iam_inline_policy_document, data.aws_iam_policy_document.inline[0].json)

  lifecycle {
    create_before_destroy = true
  }
}

#https://www.terraform.io/docs/providers/aws/d/iam_policy_document.html
data "aws_iam_policy_document" "inline" {
  #######################################
  count = local.enable_iam > 0 && var.iam_inline_policy_document == "" ? 1 : 0

  statement {
    sid = "ModifyInstanceCreditSpecification"
    actions = [
      "ec2:ModifyInstanceCreditSpecification"
    ]
    resources = ["*"]
  }
}

#https://www.terraform.io/docs/providers/aws/r/iam_instance_profile.html
resource "aws_iam_instance_profile" "this" {
  ##########################################
  count = local.enable_iam

  name_prefix = "${join(module.const.delimiter, [
    "iamInstanceProfile",
    local.instance_name,
  ])}${module.const.delimiter}"

  role = aws_iam_role.this[0].name

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${local.instance_name}${module.const.delimiter}${module.const.iam_instance_profile_suffix}"
  }
}

#пока выключено, но это нужно сделать настраиваемым
#https://www.terraform.io/docs/providers/aws/r/iam_role_policy_attachment.html
resource "aws_iam_role_policy_attachment" "this" {
  ################################################
  for_each = local.iam_policy_arns

  role       = aws_iam_role.this[0].name
  policy_arn = each.value
}
