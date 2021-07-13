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


variable "ssh_keyname" {
  type        = string
  description = "The AWS EC2/Key pair name for default account on the EC2-instance (required)."
}

variable "enable" {
  default     = false
  description = "Destroy all module resources if false (optional)."
}
