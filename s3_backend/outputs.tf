#https://www.terraform.io/docs/configuration/outputs
#################
output "enable" {
  ###############
  value = var.enable
}

#################
output "config" {
  ###############
  value = local.config
}

#####################
output "key_suffix" {
  ###################
  value = local.key_suffix
}

#####################
output "local_file" {
  ###################
  value = {
    filename = local.backend_filename
    content  = join("", data.template_file.this.*.rendered)
  }
}
