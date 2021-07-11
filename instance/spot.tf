locals {
  enable_on_demand = var.enable && var.instance != null ? lookup(
    var.instance, "enable_on_demand", null
  ) != null ? var.instance.enable_on_demand ? 1 : 0 : 0 : 0

  enable_spot = var.enable && var.instance != null ? local.enable_on_demand > 0 ? 0 : 1 : 0

  instance_name = var.enable && var.instance != null ? lookup(
    var.instance, "name", null
  ) != null ? var.instance.name : "${local.prefix}${module.const.delimiter}${module.const.instance_suffix}" : null
}

#https://www.terraform.io/docs/providers/aws/r/spot_instance_request.html
resource "aws_spot_instance_request" "this" {
  ###########################################
  count = local.enable_spot

  block_duration_minutes          = lookup(var.instance, "block_duration_minutes", null)
  instance_interruption_behaviour = lookup(var.instance, "instance_interruption_behaviour", null)
  launch_group                    = lookup(var.instance, "launch_group", null)
  spot_type                       = lookup(var.instance, "spot_type", null)
  spot_price                      = lookup(var.instance, "spot_price", null) != null ? var.instance.spot_price : lookup(var.ec2_price, var.instance.instance_type, null)
  valid_from                      = lookup(var.instance, "valid_from", null)
  valid_until                     = lookup(var.instance, "valid_until", null)
  wait_for_fulfillment            = lookup(var.instance, "wait_for_fulfillment", true)

  ami                         = var.instance.ami
  associate_public_ip_address = lookup(var.instance, "associate_public_ip_address", null)
  availability_zone           = lookup(var.instance, "availability_zone", null)

  dynamic "capacity_reservation_specification" {
    for_each = lookup(var.instance, "capacity_reservation_specification", null) == null ? [] : [var.instance.capacity_reservation_specification]
    content {
      capacity_reservation_preference = lookup(capacity_reservation_specification.value, "capacity_reservation_preference", null)

      dynamic "capacity_reservation_target" {
        for_each = lookup(capacity_reservation_specification.value, "capacity_reservation_target", null) == null ? [] : [capacity_reservation_specification.value.capacity_reservation_target]
        content {
          capacity_reservation_id = lookup(capacity_reservation_target.value, "capacity_reservation_id", null)
        }
      }
    }
  }

  cpu_core_count       = lookup(var.instance, "cpu_core_count", null)
  cpu_threads_per_core = lookup(var.instance, "cpu_threads_per_core", null)

  dynamic "credit_specification" {
    for_each = lookup(var.instance, "cpu_credits", null) == null ? [] : [true]
    content {
      cpu_credits = var.instance.cpu_credits
    }
  }

  disable_api_termination = lookup(var.instance, "disable_api_termination", null)

  dynamic "ebs_block_device" {
    for_each = lookup(var.instance, "ebs_block_device", null) == null ? [] : var.instance.ebs_block_device
    content {
      device_name           = ebs_block_device.value.device_name
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", null)
      encrypted             = lookup(ebs_block_device.value, "encrypted", null)
      iops                  = lookup(ebs_block_device.value, "iops", null)
      kms_key_id            = lookup(ebs_block_device.value, "kms_key_id", null)
      snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)
      throughput            = lookup(ebs_block_device.value, "throughput", null)
      volume_size           = lookup(ebs_block_device.value, "volume_size", null)
      volume_type           = lookup(ebs_block_device.value, "volume_type", null)
      tags                  = lookup(ebs_block_device.value, "tags", null)
    }
  }

  ebs_optimized = lookup(var.instance, "ebs_optimized", null)

  dynamic "enclave_options" {
    for_each = lookup(var.instance, "enable_enclave", null) == null ? [] : [true]
    content {
      enabled = var.instance.enable_enclave
    }
  }

  dynamic "ephemeral_block_device" {
    for_each = lookup(var.instance, "ephemeral_block_device", null) == null ? [] : var.instance.ephemeral_block_device
    content {
      device_name    = ephemeral_block_device.value.device_name
      no_device_name = lookup(ephemeral_block_device.value, "no_device_name", null)
      virtual_name   = lookup(ephemeral_block_device.value, "virtual_name", null)
    }
  }

  get_password_data = lookup(var.instance, "get_password_data", null)
  hibernation       = lookup(var.instance, "hibernation", null)
  host_id           = lookup(var.instance, "host_id", null)

  iam_instance_profile = local.enable_iam > 0 ? aws_iam_instance_profile.this[0].name : lookup(
    var.instance, "iam_instance_profile", null
  )

  instance_initiated_shutdown_behavior = lookup(var.instance, "instance_initiated_shutdown_behavior", null)
  instance_type                        = var.instance.instance_type
  ipv6_address_count                   = lookup(var.instance, "ipv6_address_count", null)
  ipv6_addresses                       = lookup(var.instance, "ipv6_addresses", null)

  key_name = local.enable_key_pair > 0 ? aws_key_pair.this[0].id : lookup(
    var.instance, "key_name", null
  )

  dynamic "metadata_options" {
    for_each = lookup(var.instance, "metadata_options", null) == null ? [] : [var.instance.metadata_options]
    content {
      http_endpoint               = lookup(metadata_options.value, "http_endpoint", null)
      http_put_response_hop_limit = lookup(metadata_options.value, "http_put_response_hop_limit", null)
      http_tokens                 = lookup(metadata_options.value, "http_tokens", null)
    }
  }

  monitoring = lookup(var.instance, "monitoring", null)

  dynamic "network_interface" {
    for_each = lookup(var.instance, "network_interface", null) == null ? [] : var.instance.network_interface
    content {
      device_index          = metadata_options.value.device_index
      network_interface_id  = metadata_options.value.network_interface_id
      delete_on_termination = lookup(network_interface.value, "delete_on_termination", null)
    }
  }

  placement_group = lookup(var.instance, "placement_group", null)
  private_ip      = lookup(var.instance, "private_ip", null)

  dynamic "root_block_device" {
    for_each = lookup(var.instance, "root_block_device", null) == null ? [] : [var.instance.root_block_device]
    content {
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", true)
      volume_size           = lookup(root_block_device.value, "volume_size", null)
      volume_type           = lookup(root_block_device.value, "volume_type", "standard")
    }
  }

  secondary_private_ips = lookup(var.instance, "secondary_private_ips", null)
  security_groups       = lookup(var.instance, "security_groups", null)
  source_dest_check     = lookup(var.instance, "source_dest_check", null)
  subnet_id             = lookup(var.instance, "subnet_id", null)
  tenancy               = lookup(var.instance, "tenancy", null)
  user_data             = lookup(var.instance, "user_data", null)
  user_data_base64      = lookup(var.instance, "user_data_base64", null)

  volume_tags = lookup(
    var.instance, "volume_tags", null
    ) != null ? var.instance.volume_tags : {
    Name = "${local.instance_name}${module.const.delimiter}${module.const.root_ebs_suffix}"
  }

  vpc_security_group_ids = lookup(var.instance, "vpc_security_group_ids", null) != null ? var.instance.vpc_security_group_ids : aws_security_group.this.*.id

  tags = {
    Name = local.instance_name
  }
}
