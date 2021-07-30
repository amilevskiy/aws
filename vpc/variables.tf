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

variable "awscli_args" {
  default     = "no"
  description = "(Optional) The AWS CLI arguments [e.g. --profile DEVOPS]"
}

variable "manage_default_vpc_dhcp_options" {
  default     = false
  description = "The flag to tag default_vpc_dhcp_options for current region"
}

variable "label" {
  type = map(string)
  default = {
    public  = "public"
    lb      = "lb"
    k8s     = "k8s"
    misc    = "misc"
    secured = "secured"
    default = "default"
  }
  description = "The labels for created resources"
}

variable "subnets_order" {
  type    = list(string)
  default = ["k8s", "misc", "public", "lb", "secured"]
}

variable "hosts" {
  type = map(number)
  default = {
    public  = 32
    lb      = 16
    k8s     = 1024
    misc    = 512
    secured = 16
  }
}

variable "max_ipv4_prefix" {
  type    = number
  default = 32
}

variable "bool2string" {
  type = map(string)
  default = {
    true  = "enable"
    false = "disable"
  }
}
