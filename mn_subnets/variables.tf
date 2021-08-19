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


variable "max_ipv4_prefix" {
  type    = number
  default = 32
}

variable "network_acl_rule_start" {
  default = 1000
}

variable "network_acl_rule_step" {
  default = 10
}


variable "client" {
  default = ""
}

variable "account" {
  default = ""
}

variable "region" {
  default = ""
}

variable "serial" {
  default = ""
}

variable "vpc_endpoint_id" {
  default = null
}
