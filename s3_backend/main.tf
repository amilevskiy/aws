################
module "const" {
  ##############
  #source = "../../const"
  #source = "github.com/ModelN/cloudops-tf-modules//voyager/const?ref=voyager_v0.0.13"
  source = "github.com/amilevskiy/const?ref=v0.1.11"
}

#https://www.terraform.io/docs/providers/null/resource.html
resource "null_resource" "backend" {
  ##################################
  count = local.enable

  triggers = {
    filename = local.backend_filename
    content  = join("", data.template_file.this.*.rendered)
  }

  provisioner "local-exec" {
    command = "test -e '${self.triggers.filename}' || echo '${self.triggers.content}' >'${self.triggers.filename}'"
  }
}
