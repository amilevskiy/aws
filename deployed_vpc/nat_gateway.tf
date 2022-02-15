variable "nat_gateway" {
  type = object({
    name_prefix = optional(string)

    allocation_id     = optional(string)
    connectivity_type = optional(string) # private and public. Defaults to public.

    network_border_group = optional(string)

    subnet_index = optional(number)

    timeouts = optional(object({
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })

  validation {
    condition = var.nat_gateway != null ? (
      var.nat_gateway.connectivity_type != null ? can(regex(
        "^(?i)(private|public)$",
        var.nat_gateway.connectivity_type
    )) : true) : true

    error_message = "The only possible values are \"private\" and \"public\"."
  }

  default = null
}


locals {
  enable_nat_gateway = local.enable_internet_gateway > 0 && (
    local.enable_subnets && var.nat_gateway != null
  ) ? var.subnets.public != null ? 1 : 0 : 0

  nat_gateway_prefix = var.nat_gateway != null ? (
    var.nat_gateway.name_prefix != null ? var.nat_gateway.name_prefix : local.prefix
  ) : null
}


#https://www.terraform.io/docs/providers/aws/r/eip
resource "aws_eip" "this" {
  #########################
  count = local.enable_nat_gateway

  vpc = true

  network_border_group = var.nat_gateway.network_border_group

  tags = merge(local.tags, {
    Name = join(module.const.delimiter, compact([
      local.nat_gateway_prefix,
      module.const.ngw_suffix,
      module.const.eip_suffix,
    ]))
  })

  dynamic "timeouts" {
    for_each = var.nat_gateway.timeouts != null ? [var.nat_gateway.timeouts] : []
    content {
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_internet_gateway.this]
}

#https://www.terraform.io/docs/providers/aws/r/nat_gateway
resource "aws_nat_gateway" "this" {
  #################################
  count = local.enable_nat_gateway

  allocation_id = aws_eip.this[0].id

  #subnet_id     = element(flatten(random_shuffle.this.*.result), 0)
  subnet_id = [for k, v in aws_subnet.this : v.id if can(regex("^(?i)public-", k))][
    var.nat_gateway.subnet_index != null ? var.nat_gateway.subnet_index : 0
  ]

  # поскольу мы не можем подготовить заранее aws_network_interface для aws_nat_gateway,
  # поэтому такой "финт ушами" для "протэггивания" ресурса
  provisioner "local-exec" {
    command = <<-COMMAND
  test '${var.awscli_args}' = 'no' ||
  	aws ${var.awscli_args} ec2 create-tags \
  		--resources ${self.network_interface_id} \
  		--tags  'Key=Name,Value=${join(module.const.delimiter, compact([local.nat_gateway_prefix, module.const.ngw_suffix, module.const.eni_suffix]))}'
  COMMAND
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.tags, {
    Name = join(module.const.delimiter, compact([
      local.nat_gateway_prefix,
      module.const.ngw_suffix,
    ]))
  })
}

##https://www.terraform.io/docs/providers/random/r/shuffle
# resource "random_shuffle" "this" {
#   ################################
#   count = local.enable_nat_gateway
#   input = [for k, v in aws_subnet.this : v.id if can(regex("^(?i)public-", k))]
#   result_count = 1
# }
