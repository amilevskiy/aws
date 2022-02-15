variable "launch_template" {
  type = object({
    name        = optional(string)
    name_prefix = optional(string)

    description = optional(string)

    default_version        = optional(number)
    update_default_version = optional(bool)

    block_device_mappings = optional(list(object({
      device_name  = optional(string)
      no_device    = optional(string)
      virtual_name = optional(string)

      ebs = optional(object({
        delete_on_termination = optional(bool)
        encrypted             = optional(bool)
        iops                  = optional(number) # Only valid for volume_type of io1, io2 or gp3.
        kms_key_id            = optional(string)
        snapshot_id           = optional(string)
        throughput            = optional(number) # only valid for volume_type of gp3.
        volume_size           = optional(number) # GiB
        volume_type           = optional(string) # standard, gp2, gp3, io1, io2, sc1, st1. Defaults to gp2.
      }))
    })))

    capacity_reservation_specification = optional(object({
      capacity_reservation_preference = optional(string) # "open" or "none". Default: "open"
      capacity_reservation_target = optional(object({
        capacity_reservation_id = optional(string)
      }))
    }))

    cpu_core_count       = optional(number)
    cpu_threads_per_core = optional(number) #1-HT is disabled. Defaults-2
    cpu_credits          = optional(string) #standard or unlimited. by default: T3-unlimited, T2-standard

    disable_api_termination = optional(bool)
    ebs_optimized           = optional(bool)

    # https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/elastic-graphics.html#elastic-gpus-basics
    elastic_gpu_type = optional(string)

#https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-inference
    elastic_inference_accelerator_type = optional(string)

    iam_instance_profile = optional(object({
      arn  = optional(string)
      name = optional(string)
    }))

    image_id                             = optional(string)
    default_volume_size                  = optional(number)
    instance_initiated_shutdown_behavior = optional(string) # stop and terminate

    instance_market_options = optional(object({
      market_type = optional(string)
      spot_options = optional(object({
        block_duration_minutes         = optional(number)
        instance_interruption_behavior = optional(string) #hibernate, stop, or terminate
        max_price                      = optional(string)
        spot_instance_type             = optional(string) #one-time, or persistent.
        valid_until                    = optional(string) #UTC RFC3339 format YYYY-MM-DDTHH:MM:SSZ
      }))
    }))

    instance_type = optional(string)
    kernel_id     = optional(string)
    key_name      = optional(string)

    license_specification = optional(list(object({
      license_configuration_arn = string
    })))

    metadata_options = optional(object({
      http_endpoint               = optional(string) # enabled or disabled
      http_put_response_hop_limit = optional(number) # 1 to 64. Defaults to 1.
      http_tokens                 = optional(string) # optional or required. Defaults to optional
    }))

    enable_enclave     = optional(bool)
    enable_hibernation = optional(bool)
    enable_monitoring  = optional(bool)

    network_interfaces = optional(list(object({
      associate_carrier_ip_address = optional(string)
      associate_public_ip_address  = optional(string)
      delete_on_termination        = optional(bool) # Defaults to false
      description                  = optional(string)
      device_index                 = optional(number)
      security_groups              = optional(list(string))
      ipv6_address_count           = optional(number)
      ipv6_addresses               = optional(list(string))
      network_interface_id         = optional(string)
      private_ip_address           = optional(string)
      ipv4_address_count           = optional(number)
      ipv4_addresses               = optional(list(string))
      subnet_id                    = optional(string)
      interface_type               = optional(string) # "efa", "interface"
    })))

    # The Placement Group of the instance.
    placement = optional(object({
      affinity                = optional(string)
      availability_zone       = optional(string)
      group_name              = optional(string)
      host_id                 = optional(string)
      host_resource_group_arn = optional(string)
      spread_domain           = optional(string)
      tenancy                 = optional(string)
      partition_number        = optional(number)
    }))

    ram_disk_id            = optional(string)
    security_group_names   = optional(list(string))
    vpc_security_group_ids = optional(list(string))

    tag_specifications = optional(list(object({
      resource_type = optional(string) # instance, volume, elastic-gpu and spot-instances-request
      tags          = map(string)
    })))

    user_data = optional(string)
  })

  # validation {
  #   condition = var.subnets != null ? lookup(
  #     var.subnets, "availability_zones", null
  #     ) != null ? length(var.subnets.availability_zones) > 0 ? lookup(
  #     var.subnets, "availability_zone_ids", null
  #   ) != null ? length(var.subnets.availability_zone_ids) == 0 : true : true : true : true

  #   error_message = "The only possible values are \"availability_zones\" or \"availability_zone_ids\"."
  # }

  default = null
}

locals {
  enable_launch_template = var.enable && var.launch_template != null ? 1 : 0

  launch_template_name = local.enable_launch_template > 0 ? (
    var.launch_template.name != null
    ) ? var.launch_template.name : (
    var.launch_template.name_prefix == null
  ) ? "${local.prefix}${module.const.delimiter}${module.const.launch_template_suffix}" : null : null
}

#https://www.terraform.io/docs/providers/aws/r/launch_template
resource "aws_launch_template" "this" {
  ###################################
  count = local.enable_launch_template

  name        = local.launch_template_name
  name_prefix = local.launch_template_name == null ? var.launch_template.name_prefix : null

  description = var.launch_template.description != null ? (
    var.launch_template.description
  ) : local.launch_template_name != null ? "${local.launch_template_name} template" : null

  default_version        = var.launch_template.default_version
  update_default_version = var.launch_template.update_default_version

  dynamic "block_device_mappings" {
    for_each = var.launch_template.block_device_mappings != null ? var.launch_template.block_device_mappings : [{
      device_name  = "/dev/sda1"
      no_device    = null
      virtual_name = null

      "ebs" = {
        delete_on_termination = true
        encrypted             = null
        iops                  = null
        kms_key_id            = null
        snapshot_id           = null
        throughput            = null
        volume_size           = var.launch_template.default_volume_size
        volume_type           = "standard"
      }
    }]
    content {
      device_name  = block_device_mappings.value.device_name
      no_device    = block_device_mappings.value.no_device
      virtual_name = block_device_mappings.value.virtual_name

      dynamic "ebs" {
        for_each = block_device_mappings.value.ebs != null ? [block_device_mappings.value.ebs] : []
        content {
          delete_on_termination = ebs.value.delete_on_termination
          encrypted             = ebs.value.encrypted
          iops                  = ebs.value.iops
          kms_key_id            = ebs.value.kms_key_id
          snapshot_id           = ebs.value.snapshot_id
          throughput            = ebs.value.throughput
          volume_size           = ebs.value.volume_size
          volume_type           = ebs.value.volume_type
        }
      }
    }
  }

  dynamic "capacity_reservation_specification" {
    for_each = var.launch_template.capacity_reservation_specification != null ? [
      var.launch_template.capacity_reservation_specification
    ] : []
    content {
      capacity_reservation_preference = capacity_reservation_specification.value.capacity_reservation_preference

      dynamic "capacity_reservation_target" {
        for_each = capacity_reservation_specification.value.capacity_reservation_target != null ? [
          capacity_reservation_specification.value.capacity_reservation_target
        ] : []
        content {
          capacity_reservation_id = capacity_reservation_target.value.capacity_reservation_id
        }
      }
    }
  }

  dynamic "cpu_options" {
    for_each = var.launch_template.cpu_core_count != null || var.launch_template.cpu_threads_per_core != null ? [true] : []
    content {
      core_count       = var.launch_template.cpu_core_count
      threads_per_core = var.launch_template.cpu_threads_per_core
    }
  }

  dynamic "credit_specification" {
    for_each = var.launch_template.cpu_credits != null ? [var.launch_template.cpu_credits] : ["standard"]
    content {
      cpu_credits = credit_specification.value
    }
  }

  disable_api_termination = var.launch_template.disable_api_termination != null ? var.launch_template.disable_api_termination : false
  ebs_optimized           = var.launch_template.ebs_optimized != null ? var.launch_template.ebs_optimized : false

  dynamic "elastic_gpu_specifications" {
    for_each = var.launch_template.elastic_gpu_type != null ? [var.launch_template.elastic_gpu_type] : []
    content {
      type = elastic_gpu_specifications.value
    }
  }

  dynamic "elastic_inference_accelerator" {
    for_each = var.launch_template.elastic_inference_accelerator_type != null ? [var.launch_template.elastic_inference_accelerator_type] : []
    content {
      type = elastic_inference_accelerator.value
    }
  }

  dynamic "iam_instance_profile" {
    for_each = var.launch_template.iam_instance_profile != null ? [var.launch_template.iam_instance_profile] : local.enable_iam > 0 ? [{
      arn  = null
      name = aws_iam_instance_profile.this[0].name
    }] : []
    content {
      arn  = iam_instance_profile.value.arn
      name = iam_instance_profile.value.name
    }
  }

  image_id = var.launch_template.image_id
  instance_initiated_shutdown_behavior = var.launch_template.instance_initiated_shutdown_behavior != null ? (
    var.launch_template.instance_initiated_shutdown_behavior
  ) : "terminate"

  dynamic "instance_market_options" {
    for_each = var.launch_template.instance_market_options != null ? [var.launch_template.instance_market_options] : []
    content {
      market_type = instance_market_options.value.market_type

      dynamic "spot_options" {
        for_each = instance_market_options.value.spot_options != null ? [instance_market_options.value.spot_options] : []
        content {
          block_duration_minutes         = spot_options.value.block_duration_minutes
          instance_interruption_behavior = spot_options.value.instance_interruption_behavior
          max_price                      = spot_options.value.max_price
          spot_instance_type             = spot_options.value.spot_instance_type
          valid_until                    = spot_options.value.valid_until
        }
      }
    }
  }

  instance_type = var.launch_template.instance_type
  kernel_id     = var.launch_template.kernel_id
  key_name      = var.launch_template.key_name != null ? var.launch_template.key_name : try(aws_key_pair.this[0].key_name, null)

  dynamic "license_specification" {
    for_each = var.launch_template.license_specification != null ? var.launch_template.license_specification : []
    content {
      license_configuration_arn = license_specification.value.license_configuration_arn
    }
  }

  dynamic "metadata_options" {
    for_each = var.launch_template.metadata_options != null ? [var.launch_template.metadata_options] : [{
      http_tokens                 = "optional"
      http_endpoint               = "enabled"
      http_put_response_hop_limit = 2
    }]
    content {
      http_endpoint               = metadata_options.value.http_endpoint
      http_put_response_hop_limit = metadata_options.value.http_put_response_hop_limit
      http_tokens                 = metadata_options.value.http_tokens
    }
  }

  dynamic "enclave_options" {
    for_each = var.launch_template.enable_enclave != null ? [var.launch_template.enable_enclave] : []
    content {
      enabled = enclave_options.value
    }
  }

  dynamic "hibernation_options" {
    for_each = var.launch_template.enable_hibernation != null ? [var.launch_template.enable_hibernation] : []
    content {
      configured = hibernation_options.value
    }
  }

  dynamic "monitoring" {
    for_each = var.launch_template.enable_monitoring != null ? [var.launch_template.enable_monitoring] : [false]
    content {
      enabled = monitoring.value
    }
  }

  dynamic "network_interfaces" {
    for_each = var.launch_template.network_interfaces != null ? var.launch_template.network_interfaces : [{
      associate_carrier_ip_address = null
      associate_public_ip_address  = true
      delete_on_termination        = true
      description                  = "${local.launch_template_name}${module.const.delimiter}${module.const.eni_suffix}"
      device_index                 = 0
      security_groups              = aws_security_group.this.*.id
      ipv6_address_count           = null
      ipv6_addresses               = null
      network_interface_id         = null
      private_ip_address           = null
      ipv4_address_count           = null
      ipv4_addresses               = null
      subnet_id                    = null
      interface_type               = null
    }]
    content {
      associate_carrier_ip_address = network_interfaces.value.associate_carrier_ip_address
      associate_public_ip_address  = network_interfaces.value.associate_public_ip_address
      delete_on_termination        = network_interfaces.value.delete_on_termination
      description                  = network_interfaces.value.description
      device_index                 = network_interfaces.value.device_index
      security_groups              = network_interfaces.value.security_groups != null ? network_interfaces.value.security_groups : aws_security_group.this.*.id
      ipv6_address_count           = network_interfaces.value.ipv6_address_count
      ipv6_addresses               = network_interfaces.value.ipv6_addresses
      network_interface_id         = network_interfaces.value.network_interface_id
      private_ip_address           = network_interfaces.value.private_ip_address
      ipv4_address_count           = network_interfaces.value.ipv4_address_count
      ipv4_addresses               = network_interfaces.value.ipv4_addresses
      subnet_id                    = network_interfaces.value.subnet_id
      interface_type               = network_interfaces.value.interface_type
    }
  }

  dynamic "placement" {
    for_each = var.launch_template.placement != null ? [var.launch_template.placement] : []
    content {
      affinity                = placement.value.affinity
      availability_zone       = placement.value.availability_zone
      group_name              = placement.value.group_name
      host_id                 = placement.value.host_id
      host_resource_group_arn = placement.value.host_resource_group_arn
      spread_domain           = placement.value.spread_domain
      tenancy                 = placement.value.tenancy
      partition_number        = placement.value.partition_number
    }
  }

  ram_disk_id = var.launch_template.ram_disk_id
  # security_group_names   = var.launch_template.security_group_names != null ? var.launch_template.security_group_names : null
  # vpc_security_group_ids = var.launch_template.vpc_security_group_ids != null ? var.launch_template.vpc_security_group_ids : aws_security_group.this.*.id

  dynamic "tag_specifications" {
    for_each = var.launch_template.tag_specifications != null ? var.launch_template.tag_specifications : []
    content {
      resource_type = tag_specifications.value.resource_type
      tags          = tag_specifications.value.tags
    }
  }

  user_data = var.launch_template.user_data != null ? var.launch_template.user_data : base64encode(
    join("\n", compact(split("\n", replace(join("\n",
      concat(
        data.template_file.prologue.*.rendered,
        data.template_file.epilogue.*.rendered,
      )),
      "/(?m)(^\\s*#[^!].*|[\\s#]+$|^	)/",
      "",
  )))))

  tags = {
    "Name" = local.launch_template_name
  }
}
