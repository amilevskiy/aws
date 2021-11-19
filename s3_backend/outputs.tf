#https://www.terraform.io/docs/configuration/outputs.html
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
    filename = local.backend_file
    content  = join("", data.template_file.this.*.rendered)
  }
}
