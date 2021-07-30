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

variable "bool2string" {
  type = map(string)
  default = {
    true  = "enable"
    false = "disable"
  }
}
