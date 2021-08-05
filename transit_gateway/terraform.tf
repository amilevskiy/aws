terraform {
  experiments = [module_variable_optional_attrs]

  #https://www.terraform.io/docs/language/providers/requirements.html#handling-local-name-conflicts
  required_providers {
    aws = {
      source = "hashicorp/aws"
      configuration_aliases = [
        aws,
        aws.peer
      ]
    }
  }
}
