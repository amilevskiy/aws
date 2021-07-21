variable "enable" {
  default     = false
  description = "(Optional) Destroy all module resources if false"
}


variable "cidr_blocks" {
  type    = list(string)
  default = []
}

variable "vpc_ids" {
  type    = list(string)
  default = []
}

variable "transit_gateway_id" {
  type    = string
  default = null
}
