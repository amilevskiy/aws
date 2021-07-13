variable "env" {
  type        = string
  description = "The prefix for all environments [e.g. IPUMB, CORE, etc.] (required)."
}

variable "aws_region" {
  default     = "eu-central-1"
  description = "AWS region. Default - Frankfurt (eu-central-1)."
}

variable "aws_profile" {
  default     = ""
  description = "The profile name to access in AWS (optional)."
}

variable "enable" {
  default     = false
  description = "Destroy all module resources if false (optional)."
}
