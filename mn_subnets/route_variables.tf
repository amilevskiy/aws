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
    for v in local.routes_sliced : [
      for vv in split(",", v[0]) : join(" ", [vv, v[1]])
    ] if try(v[1], "") != ""
  ]) # list(string)

  routes = {
    for v in local.routes_expanded : split(" ", v)[0] => split(" ", v)[1]
  } # map(string)
}
