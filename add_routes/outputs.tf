#################
output "enable" {
  ###############
  value = var.enable
}

#################
output "routes" {
  ###############
  value = aws_route.this
}
