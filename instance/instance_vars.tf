variable "instance" {
  type = object({
    name = optional(string)

    enable_on_demand = optional(bool)

    block_duration_minutes          = optional(number) # 60, 120, 180, 240, 300, or 360
    instance_interruption_behaviour = optional(string) # Default is terminate
    launch_group                    = optional(string)
    spot_type                       = optional(string) # Default: persistent. one-time
    spot_price                      = optional(string) # Default: on-demand
    valid_from                      = optional(string) # UTC RFC3339 format YYYY-MM-DDTHH:MM:SSZ
    valid_until                     = optional(string) # UTC RFC3339 format YYYY-MM-DDTHH:MM:SSZ
    wait_for_fulfillment            = optional(bool)   # Default: false

    ami                         = string
    associate_public_ip_address = optional(bool)
    availability_zone           = optional(string)

    capacity_reservation_specification = optional(object({
      capacity_reservation_preference = optional(string) # "open" or "none". Default: "open"
      capacity_reservation_target = optional(object({
        capacity_reservation_id = optional(string)
      }))
    }))

    cpu_core_count          = optional(number)
    cpu_threads_per_core    = optional(number) #1-HT is disabled. Defaults-2
    cpu_credits             = optional(string) #standard or unlimited. by default: T3-unlimited, T2-standard
    disable_api_termination = optional(bool)

    #aws_ebs_volume and aws_volume_attachment
    #https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume
    ebs_block_device = optional(list(object({
      device_name           = string
      delete_on_termination = optional(bool)
      encrypted             = optional(bool)
      iops                  = optional(number) # Only valid for volume_type of io1, io2 or gp3.
      kms_key_id            = optional(string)
      snapshot_id           = optional(string)
      throughput            = optional(number) # only valid for volume_type of gp3.
      volume_size           = optional(number) # GiB
      volume_type           = optional(string) # standard, gp2, gp3, io1, io2, sc1, st1. Defaults to gp2.
      tags                  = optional(map(string))
    })))

    ebs_optimized  = optional(bool)
    enable_enclave = optional(bool)

    ephemeral_block_device = optional(list(object({
      device_name    = string
      no_device_name = optional(bool)
      virtual_name   = optional(string) # e.g. ephemeral0
    })))

    get_password_data                    = optional(bool)
    hibernation                          = optional(bool)
    host_id                              = optional(string)
    iam_instance_profile                 = optional(string)
    instance_initiated_shutdown_behavior = optional(string) # stop and terminate
    instance_type                        = string
    ipv6_address_count                   = optional(number)
    ipv6_addresses                       = optional(list(string))

    key_name   = optional(string)
    public_key = optional(string)

    metadata_options = optional(object({
      http_endpoint               = optional(string) # enabled or disabled
      http_put_response_hop_limit = optional(number) # 1 to 64. Defaults to 1.
      http_tokens                 = optional(string) # optional or required. Defaults to optional
    }))

    enable_monitoring = optional(bool)

    network_interface = optional(list(object({
      device_index          = number
      network_interface_id  = string
      delete_on_termination = optional(bool) # Defaults to false
    })))

    placement_group = optional(string)
    private_ip      = optional(string)

    // "You can only modify the volume size, volume type, and Delete on
    // Termination flag on the block device mapping entry for the root
    // device volume."
    // https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/block-device-mapping-concepts.html
    root_block_device = optional(object({
      delete_on_termination = optional(bool)
      volume_size           = optional(number) # GiB
      volume_type           = optional(string) # standard, gp2, gp3, io1, io2, sc1, st1. Defaults to gp2.
    }))

    # A list of secondary private IPv4 addresses to assign to the instance's primary network interface (eth0) in a VPC. Can only be assigned to the primary network interface (eth0) attached at instance creation, not a pre-existing network interface i.e. referenced in a network_interface block. Refer to the Elastic network interfaces documentation to see the maximum number of private IP addresses allowed per instance type.
    secondary_private_ips = optional(list(string))
    security_groups       = optional(list(string))
    source_dest_check     = optional(bool) # Defaults true.

    subnet_id  = optional(string)
    subnet_ids = optional(list(string))

    tenancy                = optional(string) #Dedicated, Default,Host,
    user_data              = optional(string)
    user_data_base64       = optional(string)
    volume_tags            = optional(map(string))
    vpc_security_group_ids = optional(list(string))

    timeouts = optional(object({
      create = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
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
