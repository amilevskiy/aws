variable "enable" {
  default     = false
  description = "Destroy all module resources if false"
}

variable "env" {
  default     = ""
  description = "The name of target environment"
}

variable "name" {
  default     = ""
  description = "The component of tag-name"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags which should be assigned to all module resources"
}

variable "awscli_args" {
  default     = "no"
  description = "The AWS CLI arguments [e.g. --profile DEVOPS]"
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
  type        = list(string)
  default     = ["k8s", "misc", "public", "lb", "secured"]
  description = "The order of subnets"
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
  description = "The number of hosts in each subnet"
}

variable "max_ipv4_prefix" {
  type        = number
  default     = 32
  description = "/32 for CIDR"
}

variable "bool2string" {
  type = map(string)
  default = {
    true  = "enable"
    false = "disable"
  }
  description = "The map for conversion from bool value to string representation"
}
