variable "tags" {
  type        = map(string)
  default     = {}
  description = "(Optional) A mapping of tags which should be assigned to all module resources"
}


variable "enable" {
  default     = false
  description = "Destroy all module resources if false (optional)."
}

variable "name" {
  default = ""
}

variable "name_suffix" {
  type = map(string)
  default = {
    main        = "",
    main-log    = "log",
    replica     = "replica",
    replica-log = "replica-log",
  }
}

variable "account_id" {
  default = ""

  validation {
    condition = can(regex("^([0-9]{12,}|)$", var.account_id))

    error_message = "Invalid value of \"account_id\"."
  }
}

variable "default_s3_bucket_suffix" {
  default = ""
}

variable "kms_main_key_arn" {
  type    = string
  default = null
}

variable "kms_replica_key_arn" {
  type    = string
  default = null
}

variable "replica_role_permissions_boundary" {
  type    = string
  default = null
}

variable "s3_bucket_allowed_services" {
  type    = list(string)
  default = []
}
