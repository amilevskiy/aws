variable "tf_stack" {
  type = object({
    client  = string
    account = string
    region  = string
    env     = string
    serial  = number
  })

  default = null
}

locals {
  tf_stack = var.tf_stack != null ? join(module.const.underscore, [
    var.tf_stack.client,
    var.tf_stack.account,
    var.tf_stack.region,
    var.tf_stack.env,
    format("%05d", var.tf_stack.serial),
  ]) : ""
}
