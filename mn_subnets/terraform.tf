terraform {
  experiments = [module_variable_optional_attrs]

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    metadata = {
      source = "skeggse/metadata"
    }
    # cidr = {
    #   source = "hashicorp/cidr"
    # }
  }
}
