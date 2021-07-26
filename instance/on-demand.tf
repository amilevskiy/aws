#https://www.terraform.io/docs/providers/aws/r/instance.html
resource "aws_instance" "this" {
  ##############################
  count = local.enable_on_demand

  ami                         = var.instance.ami
  associate_public_ip_address = var.instance.associate_public_ip_address
  availability_zone           = var.instance.availability_zone

  dynamic "capacity_reservation_specification" {
    for_each = var.instance.capacity_reservation_specification != null ? [
      var.instance.capacity_reservation_specification
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

  cpu_core_count       = var.instance.cpu_core_count
  cpu_threads_per_core = var.instance.cpu_threads_per_core

  dynamic "credit_specification" {
    for_each = var.instance.cpu_credits != null ? [true] : []
    content {
      cpu_credits = var.instance.cpu_credits
    }
  }

  disable_api_termination = var.instance.disable_api_termination

  dynamic "ebs_block_device" {
    for_each = var.instance.ebs_block_device != null ? var.instance.ebs_block_device : []
    content {
      device_name           = ebs_block_device.value.device_name
      delete_on_termination = ebs_block_device.value.delete_on_termination
      encrypted             = ebs_block_device.value.encrypted
      iops                  = ebs_block_device.value.iops
      kms_key_id            = ebs_block_device.value.kms_key_id
      snapshot_id           = ebs_block_device.value.snapshot_id
      throughput            = ebs_block_device.value.throughput
      volume_size           = ebs_block_device.value.volume_size
      volume_type           = ebs_block_device.value.volume_type
      tags                  = ebs_block_device.value.tags
    }
  }

  ebs_optimized = var.instance.ebs_optimized

  dynamic "enclave_options" {
    for_each = var.instance.enable_enclave != null ? [true] : []
    content {
      enabled = var.instance.enable_enclave
    }
  }

  dynamic "ephemeral_block_device" {
    for_each = var.instance.ephemeral_block_device != null ? var.instance.ephemeral_block_device : []
    content {
      device_name  = ephemeral_block_device.value.device_name
      no_device    = ephemeral_block_device.value.no_device
      virtual_name = ephemeral_block_device.value.virtual_name
    }
  }

  get_password_data = var.instance.get_password_data
  hibernation       = var.instance.hibernation
  host_id           = var.instance.host_id

  iam_instance_profile = local.enable_iam > 0 ? (
    aws_iam_instance_profile.this[0].name
  ) : var.instance.iam_instance_profile

  instance_initiated_shutdown_behavior = var.instance.instance_initiated_shutdown_behavior
  instance_type                        = var.instance.instance_type
  ipv6_address_count                   = var.instance.ipv6_address_count
  ipv6_addresses                       = var.instance.ipv6_addresses

  key_name = local.enable_key_pair > 0 ? aws_key_pair.this[0].id : var.instance.key_name

  dynamic "metadata_options" {
    for_each = var.instance.metadata_options != null ? [var.instance.metadata_options] : []
    content {
      http_endpoint               = metadata_options.value.http_endpoint
      http_put_response_hop_limit = metadata_options.value.http_put_response_hop_limit
      http_tokens                 = metadata_options.value.http_tokens
    }
  }

  monitoring = var.instance.monitoring

  dynamic "network_interface" {
    for_each = var.instance.network_interface != null ? var.instance.network_interface : []
    content {
      device_index          = metadata_options.value.device_index
      network_interface_id  = metadata_options.value.network_interface_id
      delete_on_termination = network_interface.value.delete_on_termination
    }
  }

  placement_group = var.instance.placement_group
  private_ip      = var.instance.private_ip

  dynamic "root_block_device" {
    for_each = var.instance.root_block_device != null ? [var.instance.root_block_device] : []
    content {
      delete_on_termination = root_block_device.value.delete_on_termination != null ? (
        root_block_device.value.delete_on_termination
      ) : true
      volume_size = root_block_device.value.volume_size
      volume_type = root_block_device.value.volume_type != null ? (
        root_block_device.value.volume_type
      ) : "standard"
    }
  }

  secondary_private_ips = var.instance.secondary_private_ips
  security_groups       = var.instance.security_groups
  source_dest_check     = var.instance.source_dest_check
  subnet_id             = var.instance.subnet_id
  tenancy               = var.instance.tenancy
  user_data             = var.instance.user_data
  user_data_base64      = var.instance.user_data_base64

  volume_tags = var.instance.volume_tags != null ? var.instance.volume_tags : {
    Name = "${local.instance_name}${module.const.delimiter}${module.const.root_ebs_suffix}"
  }

  vpc_security_group_ids = var.instance.vpc_security_group_ids != null ? (
    var.instance.vpc_security_group_ids
  ) : aws_security_group.this.*.id

  tags = {
    Name = local.instance_name
  }
}
