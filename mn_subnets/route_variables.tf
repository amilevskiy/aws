variable "route_table" {
  type = object({
    propagating_vgws = optional(set(string))
    routes           = optional(set(string))
  })

  default = null
}


locals {
  enable_route_table = var.enable && var.route_table != null ? 1 : 0

  routes_sliced = (local.enable_route_table > 0
    ? var.route_table.routes != null
    ? [for v in var.route_table.routes : split(" ", lower(replace(v, "/\\s+/", " ")))]
  : [] : []) # list(list(string))

  routes_expanded = flatten([
    for v in local.routes_sliced : can(split(",", v[0])) ? [
      for vv in split(",", v[0]) : join(" ", concat(
        [vv], try(slice(v, 1, length(v)), [])
    ))] : [join(" ", v)]
  ]) # list(string)

  routes = {
    for v in local.routes_expanded : split(" ", v)[0] => split(" ", v)[1]
  } # map(string)

  # route_keys = flatten([
  #   for v in setproduct(local.subnets_keys, keys(local.route_map)) : join(":", v)
  # ]) # list(string)

  # routes = {
  #   for v in local.route_keys : v => local.route_map[split(":", v)[1]]
  # }
}
