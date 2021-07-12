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

# variable "availability_zones" {
#   type        = list(string)
#   default     = []
#   description = "(Optional) The list of availability zone names"
# }

# variable "availability_zone_ids" {
#   type        = list(string)
#   default     = []
#   description = "(Optional) The list of availability zone ids"
# }

variable "public_label" {
  default     = "public"
  description = "The label for public subnets and route tables"
}

variable "lb_label" {
  default     = "lb"
  description = "The label for lb subnets and route tables"
}

variable "k8s_label" {
  default     = "k8s"
  description = "The label for k8s subnets and route tables"
}

variable "misc_label" {
  default     = "misc"
  description = "The label for miscellaneous subnets and route tables"
}

variable "secured_label" {
  default     = "secured"
  description = "The label for secured subnets and route tables"
}

variable "default_label" {
  default     = "default"
  description = "The label for resources created by default"
}

variable "manage_default_vpc_dhcp_options" {
  default     = false
  description = "The flag to tag default_vpc_dhcp_options for current region"
}
