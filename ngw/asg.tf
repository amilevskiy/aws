variable "autoscaling_group" {
  type = object({
    name        = optional(string)
    name_prefix = optional(string)

    max_size         = number
    min_size         = number
    desired_capacity = optional(number)

    capacity_rebalance = optional(bool)
    default_cooldown   = optional(number)

    launch_configuration = optional(string)
    launch_template = optional(object({
      id      = optional(string)
      name    = optional(string)
      version = optional(string) # Can be version number, $Latest, or $Default. Default: $Default
    }))

    mixed_instances_policy = optional(object({
      instances_distribution = optional(object({
        on_demand_allocation_strategy            = optional(string) # Valid values: prioritized. Default: prioritized
        on_demand_base_capacity                  = optional(number) # Default: 0
        on_demand_percentage_above_base_capacity = optional(number) # Default: 100
        spot_allocation_strategy                 = optional(string) # lowest-price, capacity-optimized, capacity-optimized-prioritized. Default: lowest-price
        spot_instance_pools                      = optional(number) # Default: 2
        spot_max_price                           = optional(string) # Default: an empty string which means the on-demand price

      }))

      launch_template = optional(object({
        launch_template_specification = optional(object({
          launch_template_id   = optional(string)
          launch_template_name = optional(string)
          version              = optional(string) # Can be version number, $Latest, or $Default. Default: $Default
        }))

        override = optional(list(object({
          instance_type     = optional(string)
          weighted_capacity = optional(string)
          launch_template_specification = optional(object({
            launch_template_id   = optional(string)
            launch_template_name = optional(string)
            version              = optional(string) # Can be version number, $Latest, or $Default. Default: $Default
          }))
        })))
      }))
    }))

    initial_lifecycle_hook = optional(list(object({
      name                    = string
      default_result          = optional(string)
      heartbeat_timeout       = optional(number)
      lifecycle_transition    = string
      notification_metadata   = optional(string)
      notification_target_arn = optional(string)
      role_arn                = optional(string)
    })))

    health_check_grace_period = optional(number) # Default: 300
    health_check_type         = optional(string) # "EC2" or "ELB"
    force_delete              = optional(bool)

    availability_zones  = optional(list(string))
    vpc_zone_identifier = optional(list(string))

    load_balancers    = optional(list(string))
    target_group_arns = optional(list(string))

    termination_policies = optional(list(string))
    suspended_processes  = optional(list(string))

    placement_group     = optional(string)
    metrics_granularity = optional(string) # Default: "1Minute"

    enabled_metrics           = optional(list(string))
    wait_for_capacity_timeout = optional(string) # Default: "10m"

    min_elb_capacity      = optional(number)
    wait_for_elb_capacity = optional(number)

    protect_from_scale_in   = optional(bool)
    service_linked_role_arn = optional(string)
    max_instance_lifetime   = optional(number)

    instance_refresh = optional(object({
      strategy = string
      preferences = optional(object({
        instance_warmup        = optional(number)
        min_healthy_percentage = optional(number)
      }))
      triggers = optional(list(string))
    }))

    warm_pool = optional(object({
      pool_state                  = optional(string)
      min_size                    = optional(number)
      max_group_prepared_capacity = optional(number)
    }))

    force_delete_warm_pool = optional(bool)

    tag = optional(list(object({
      propagate_at_launch = bool
      key                 = string
      value               = string
    })))
  })
  default = null
}

locals {
  enable_autoscaling_group = var.enable && var.autoscaling_group != null ? 1 : 0

  autoscaling_group_name = local.enable_autoscaling_group > 0 ? (
    var.autoscaling_group.name != null
    ) ? var.autoscaling_group.name : (
    var.autoscaling_group.name_prefix == null
  ) ? "${local.prefix}${module.const.delimiter}${module.const.asg_suffix}" : null : null
}

#https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html
resource "aws_autoscaling_group" "this" {
  #######################################
  count = local.enable_autoscaling_group

  name        = local.autoscaling_group_name
  name_prefix = local.autoscaling_group_name == null ? var.autoscaling_group.name_prefix : null

  max_size         = var.autoscaling_group.max_size
  min_size         = var.autoscaling_group.min_size
  desired_capacity = var.autoscaling_group.desired_capacity

  capacity_rebalance = var.autoscaling_group.capacity_rebalance
  default_cooldown   = var.autoscaling_group.default_cooldown

  launch_configuration = var.autoscaling_group.launch_configuration

  dynamic "launch_template" {
    for_each = var.autoscaling_group.launch_template != null ? [var.autoscaling_group.launch_template] : []
    content {
      id      = launch_template.value.id
      name    = launch_template.value.name
      version = launch_template.value.version
    }
  }

  dynamic "mixed_instances_policy" {
    for_each = var.autoscaling_group.mixed_instances_policy != null ? [var.autoscaling_group.mixed_instances_policy] : []
    content {

      dynamic "launch_template" {
        for_each = mixed_instances_policy.value.launch_template != null ? [mixed_instances_policy.value.launch_template] : []
        content {
          dynamic "launch_template_specification" {
            for_each = launch_template.value.launch_template_specification != null ? [launch_template.value.launch_template_specification] : []
            content {
              launch_template_id = launch_template_specification.value.launch_template_id != null ? launch_template_specification.value.launch_template_id : try(
                aws_launch_template.this[0].id, null
              )

              launch_template_name = launch_template_specification.value.launch_template_name
              version              = launch_template_specification.value.version
            }
          }

          dynamic "override" {
            for_each = launch_template.value.override != null ? launch_template.value.override : []
            content {
              instance_type     = override.value.instance_type
              weighted_capacity = override.value.weighted_capacity

              dynamic "launch_template_specification" {
                for_each = override.value.launch_template_specification != null ? [override.value.launch_template_specification] : []
                content {
                  launch_template_id   = launch_template_specification.value.launch_template_id
                  launch_template_name = launch_template_specification.value.launch_template_name
                  version              = launch_template_specification.value.version
                }
              }
            }
          }
        }
      }

      dynamic "instances_distribution" {
        for_each = mixed_instances_policy.value.instances_distribution != null ? [mixed_instances_policy.value.instances_distribution] : []
        content {
          on_demand_allocation_strategy            = instances_distribution.value.on_demand_allocation_strategy
          on_demand_base_capacity                  = instances_distribution.value.on_demand_base_capacity
          on_demand_percentage_above_base_capacity = instances_distribution.value.on_demand_percentage_above_base_capacity
          spot_allocation_strategy                 = instances_distribution.value.spot_allocation_strategy
          spot_instance_pools                      = instances_distribution.value.spot_instance_pools
          spot_max_price                           = instances_distribution.value.spot_max_price
        }
      }
    }
  }

  dynamic "initial_lifecycle_hook" {
    for_each = var.autoscaling_group.initial_lifecycle_hook != null ? var.autoscaling_group.initial_lifecycle_hook : []
    content {
      name                    = initial_lifecycle_hook.value.name
      default_result          = initial_lifecycle_hook.value.default_result
      heartbeat_timeout       = initial_lifecycle_hook.value.heartbeat_timeout
      lifecycle_transition    = initial_lifecycle_hook.value.lifecycle_transition
      notification_metadata   = initial_lifecycle_hook.value.notification_metadata
      notification_target_arn = initial_lifecycle_hook.value.notification_target_arn
      role_arn                = initial_lifecycle_hook.value.role_arn
    }
  }

  health_check_grace_period = var.autoscaling_group.health_check_grace_period
  health_check_type         = var.autoscaling_group.health_check_type
  force_delete              = var.autoscaling_group.force_delete

  availability_zones  = var.autoscaling_group.availability_zones
  vpc_zone_identifier = var.autoscaling_group.vpc_zone_identifier

  load_balancers    = var.autoscaling_group.load_balancers
  target_group_arns = var.autoscaling_group.target_group_arns

  termination_policies = var.autoscaling_group.termination_policies
  suspended_processes  = var.autoscaling_group.suspended_processes

  placement_group     = var.autoscaling_group.placement_group
  metrics_granularity = var.autoscaling_group.metrics_granularity

  enabled_metrics           = var.autoscaling_group.enabled_metrics
  wait_for_capacity_timeout = var.autoscaling_group.wait_for_capacity_timeout

  min_elb_capacity      = var.autoscaling_group.min_elb_capacity
  wait_for_elb_capacity = var.autoscaling_group.wait_for_elb_capacity

  protect_from_scale_in   = var.autoscaling_group.protect_from_scale_in
  service_linked_role_arn = var.autoscaling_group.service_linked_role_arn
  max_instance_lifetime   = var.autoscaling_group.max_instance_lifetime

  dynamic "instance_refresh" {
    for_each = var.autoscaling_group.instance_refresh != null ? [var.autoscaling_group.instance_refresh] : []
    content {
      strategy = instance_refresh.value.strategy
      triggers = instance_refresh.value.triggers

      dynamic "preferences" {
        for_each = instance_refresh.value.preferences != null ? [instance_refresh.value.preferences] : []
        content {
          instance_warmup        = preferences.value.instance_warmup
          min_healthy_percentage = preferences.value.min_healthy_percentage
        }
      }
    }
  }

  dynamic "warm_pool" {
    for_each = var.autoscaling_group.warm_pool != null ? [var.autoscaling_group.warm_pool] : []
    content {
      pool_state                  = warm_pool.value.pool_state
      min_size                    = warm_pool.value.min_size
      max_group_prepared_capacity = warm_pool.value.max_group_prepared_capacity
    }
  }

  force_delete_warm_pool = var.autoscaling_group.force_delete_warm_pool

  depends_on = [aws_launch_template.this]

  dynamic "tag" {
    for_each = var.autoscaling_group.tag != null ? var.autoscaling_group.tag : []
    content {
      propagate_at_launch = tag.value.propagate_at_launch
      key                 = tag.value.key
      value               = tag.value.value
    }
  }
}
