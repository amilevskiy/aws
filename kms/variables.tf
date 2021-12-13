variable "tags" {
  type        = map(string)
  default     = {}
  description = "(Optional) A mapping of tags which should be assigned to all module resources"
}


variable "enable" {
  default     = false
  description = "Destroy all module resources if false (optional)."
}


variable "description" {
  type    = string
  default = null
}

variable "key_usage" {
  type    = string
  default = null

  validation {
    condition = (var.key_usage != null
      ? contains(["ENCRYPT_DECRYPT", "SIGN_VERIFY"], var.key_usage) : true
    )

    error_message = "Invalid value of \"key_usage\"."
  }
}

variable "customer_master_key_spec" {
  type    = string
  default = null

  validation {
    condition = (var.customer_master_key_spec != null ? contains([
      "SYMMETRIC_DEFAULT", "RSA_2048", "RSA_3072", "RSA_4096",
      "ECC_NIST_P256", "ECC_NIST_P384", "ECC_NIST_P521", "ECC_SECG_P256K1"
    ], var.customer_master_key_spec) : true)

    error_message = "Invalid value of \"customer_master_key_spec\"."
  }
}

variable "bypass_policy_lockout_safety_check" {
  type    = bool
  default = null
}

variable "deletion_window_in_days" {
  type    = number
  default = null

  validation {
    condition = (var.deletion_window_in_days != null ?
      7 <= var.deletion_window_in_days && var.deletion_window_in_days <= 30
    : true)

    error_message = "Value of \"deletion_window_in_days\" must be between 7 and 30 inclusive."
  }
}

variable "enable_key_rotation" {
  type    = bool
  default = null
}

variable "multi_region" {
  type    = bool
  default = null
}

variable "policy" {
  type    = string
  default = null
}

variable "name_prefix" {
  default = ""
}

variable "replica_word" {
  default = "replica"
}

variable "replica_policy" {
  type    = string
  default = null
}
