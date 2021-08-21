variable "enable" {
  default     = false
  description = "(Optional) Destroy all module resources if false"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "(Optional) A mapping of tags which should be assigned to all module resources"
}

variable "network_acl_rule_start" {
  type    = number
  default = 1000
}

variable "network_acl_rule_step" {
  type    = number
  default = 10
}

variable "vpc_id" {
  type = string
}

variable "vpc_endpoint_type_gateway_ids" {
  type    = map(string)
  default = null
}

variable "availability_zone" {
  type    = string
  default = null
}

variable "availability_zone_id" {
  type    = string
  default = null
}

variable "map_public_ip_on_launch" {
  type    = bool
  default = null
}
