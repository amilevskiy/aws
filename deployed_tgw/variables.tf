variable "enable" {
  default     = false
  description = "(Optional) Destroy all module resources if false"
}

variable "env" {
  default     = ""
  description = "(Optional) The name of target environment"
}

variable "name" {
  default     = ""
  description = "(Optional) The component of tag-name"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "(Optional) A mapping of tags which should be assigned to all module resources"
}


variable "leader_resource_share_name" {
  type    = string
  default = ""
}

variable "leader_resource_share_tag_name" {
  type    = string
  default = ""
}

variable "leader_allow_external_principals" {
  type    = bool
  default = true
}

variable "leader_resource_arn" {
  type    = string
  default = null
}

variable "leader_tgw_id" {
  type    = string
  default = "tgw-06773499e1535c4e9"
}

variable "follower_principal" {
  type    = string
  default = null
}

variable "transit_gateway_route_table_id" {
  type    = string
  default = ""
}

variable "routes" {
  type    = map(list(string))
  default = null
}
