variable "vpc" {
  type = object({
    id                 = string
    cidr_block         = string
    subnet_cidr_blocks = optional(set(string))

    update = optional(bool)
  })

  default = null
}

locals {
  enable_vpc = var.enable && var.vpc != null ? 1 : 0

  # vpc_id             = try(metadata_value.vpc[0].outputs.id, var.vpc.id)
  # vpc_cidr_block     = try(metadata_value.vpc[0].outputs.cidr_block, var.vpc.cidr_block)
  # subnet_cidr_blocks = try(split(" ", metadata_value.vpc[0].outputs.subnet_cidr_blocks), var.vpc.subnet_cidr_blocks, [])
  # vpc_id             = join("", metadata_value.vpc.*.outputs.id)
  # vpc_cidr_block     = join("", metadata_value.vpc.*.outputs.cidr_block)
  # subnet_cidr_blocks = try(split(" ", metadata_value.vpc[0].outputs.subnet_cidr_blocks), [])

  vpc_id             = var.vpc.id
  vpc_cidr_block     = var.vpc.cidr_block
  subnet_cidr_blocks = var.vpc.subnet_cidr_blocks != null ? var.vpc.subnet_cidr_blocks : []

  # result_cidr_blocks = flatten([for v in data.external.cidr.*.result.cidr_blocks : split(" ", v)])
}

# #https://registry.terraform.io/providers/skeggse/metadata/latest/docs/resources/value

# resource "metadata_value" "vpc" {
#   ###############################
#   count = local.enable_vpc

#   update = var.vpc.update

#   inputs = {
#     id                 = var.vpc.id
#     cidr_block         = var.vpc.cidr_block
#     subnet_cidr_blocks = var.vpc.subnet_cidr_blocks != null ? join(" ", var.vpc.subnet_cidr_blocks) : null
#   }
# }

# #https://www.terraform.io/docs/providers/random/r/shuffle.html
# resource "random_shuffle" "allocated_cidrs" {
#   ###########################################
#   count = local.enable_vpc

#   keepers = {
#     vpc_id         = var.vpc.id
#     vpc_cidr_block = var.vpc.cidr_block
#   }

#   # input = var.vpc.subnet_cidr_blocks != null ? var.vpc.subnet_cidr_blocks : []
#   # input = flatten([for v in data.external.cidr.*.result.cidr_blocks : split(" ", v)])
#   input = [for i in range(length(local.result_cidr_blocks)) : format("%0*d:%s", ceil(log(length(local.result_cidr_blocks), 10)), local.result_cidr_blocks[i])]
# }
