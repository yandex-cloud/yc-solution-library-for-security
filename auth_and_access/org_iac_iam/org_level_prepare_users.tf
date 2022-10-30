locals {
  user_list = <<-EOT
    ${var.CLOUD-LIST[0].admin}:${random_password.passwords[0].result}
    ${var.CLOUD-LIST[1].admin}:${random_password.passwords[1].result}
    ${var.CLOUD-LIST[2].admin}:${random_password.passwords[2].result}
  EOT
}

#Generate passwords
resource "random_password" "passwords" {
  count   = 3
  length  = 20
  special = true
}

resource "local_file" "kc-users-lst" {
  filename = "./module_keycloak/kc-users.lst"
  content  = local.user_list
}