#################
output "enable" {
  ###############
  value = var.enable
}

# #################
# output "policy" {
#   ###############
#   value = join("", data.aws_iam_policy_document.this.*.json)
# }
