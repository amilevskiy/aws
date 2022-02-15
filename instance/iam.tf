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

  iam_name = local.enable_iam > 0 ? var.iam.name != null ? (
    var.iam.name
  ) : local.instance_name : null

  iam_inline_policy_document = local.enable_iam > 0 ? (
    var.iam.inline_policy_document != null
  ) ? var.iam.inline_policy_document : "" : ""

  iam_inline_policy_document_sure = (local.iam_inline_policy_document != ""
    ? local.iam_inline_policy_document
    : can(regex("^t[2-9]a?\\..*", var.instance.instance_type)) ? jsonencode({
      Version = module.const.policy_version
      Statement : [{
        Sid      = "ModifyInstanceCreditSpecification"
        Effect   = "Allow"
        Action   = "ec2:ModifyInstanceCreditSpecification"
        Resource = "*"
  }] }) : "")

  iam_policy_arns = local.enable_iam > 0 ? var.iam.policy_arns != null ? {
    for v in var.iam.policy_arns : replace(v, "/\\//", "") => v
  } : {} : {}
}

#https://www.terraform.io/docs/providers/aws/r/iam_role.html
resource "aws_iam_role" "this" {
  ##############################
  count = local.enable_iam

  name_prefix = "${replace(substr(join(module.const.delimiter, [
    "iamRole",
    local.iam_name,
  ]), 0, 32 - length(module.const.delimiter)), "/-+$/", "")}${module.const.delimiter}"

  description = "Allows access to AWS resources for ${local.instance_name}-instance"

  assume_role_policy = jsonencode({
    Version = module.const.policy_version
    Statement : [{
      Sid    = "Ec2TrustRelationshipPolicy"
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "ec2.amazonaws.com"
      },
  }] })

  dynamic "inline_policy" {
    for_each = local.iam_inline_policy_document_sure != "" ? [local.iam_inline_policy_document_sure] : []
    content {
      name   = join(module.const.delimiter, ["iamInlinePolicy", local.iam_name])
      policy = inline_policy.value
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${local.iam_name}${module.const.delimiter}${module.const.iam_role_suffix}"
  }
}

# #https://www.terraform.io/docs/providers/aws/r/iam_role_policy.html
# resource "aws_iam_role_policy" "this" {
#   #####################################
#   count = local.iam_inline_policy_document_sure != "" ? 1 : 0
#   name_prefix = "${join(module.const.delimiter, [
#     "iamInlinePolicy",
#     local.iam_name,
#   ])}${module.const.delimiter}"
#   role   = aws_iam_role.this[0].name
#   policy = local.iam_inline_policy_document_sure
#   lifecycle {
#     create_before_destroy = true
#   }
# }

#https://www.terraform.io/docs/providers/aws/r/iam_instance_profile.html
resource "aws_iam_instance_profile" "this" {
  ##########################################
  count = local.enable_iam

  name_prefix = "${replace(substr(join(module.const.delimiter, [
    "iamProfile",
    local.iam_name,
  ]), 0, 64 - length(module.const.delimiter)), "/-+$/", "")}${module.const.delimiter}"

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
