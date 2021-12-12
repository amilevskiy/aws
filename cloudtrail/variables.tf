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

    error_message = "Invalid valued of \"account_id\"."
  }
}

variable "default_s3_bucket_suffix" {
  default = ""
}
