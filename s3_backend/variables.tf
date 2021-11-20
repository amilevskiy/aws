variable "enable" {
  default     = true
  description = "Flag to enable module (optional)."
}

variable "region" {
  default     = ""
  description = "The region where stored in S3 bootstrap state (optional)."
}

variable "profile" {
  default     = ""
  description = "The AWS cli profile name to access to S3 bootstrap state (optional)."
}

variable "role_arn" {
  default     = ""
  description = "The IAM role to access to S3 bootstrap state (optional)."
}

variable "backend_account_id" {
  default     = "226896994788"
  description = "The account_id where stored in S3 bootstrap state (optional)."
}

variable "bucket" {
  default     = ""
  description = "S3 bucket where stored bootstrap state (optional)."
}

variable "key" {
  default     = ""
  description = "S3 path where stored bootstrap state (optional)."
}

variable "skip_credentials_validation" {
  default     = true
  description = "https://www.terraform.io/docs/language/settings/backends/s3.html#skip_credentials_validation"
}

variable "skip_region_validation" {
  default     = true
  description = "https://www.terraform.io/docs/language/settings/backends/s3.html#skip_region_validation"
}

variable "skip_metadata_api_check" {
  default     = true
  description = "https://www.terraform.io/docs/language/settings/backends/s3.html#skip_metadata_api_check"
}

variable "key_suffix" {
  default     = ""
  description = "S3 path to substitute in backend template (optional)."
}

variable "backend_filename" {
  default     = ""
  description = "The name of local file that will plan storing configuration (optional)."
}

variable "default_directory_prefix" {
  default = "010"
}

variable "default_bucket_suffix" {
  default = "networking"
}
