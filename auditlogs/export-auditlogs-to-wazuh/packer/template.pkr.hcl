variable "source_image_family" {
  type    = string
  default = "ubuntu-2004-lts"
}
variable "ssh_username" {
  type    = string
  default = "ubuntu"
}
variable "token" {
  default = env("YC_TOKEN")
}
source "yandex" "wazuh" {
  source_image_family = var.source_image_family
  ssh_username        = var.ssh_username
  token               = var.token
  use_ipv4_nat        = "true"
  image_name          = "wazuh-{{isotime \"02-Jan-06-03-04-05\" | lower }}"
}

build {
  sources = ["source.yandex.wazuh"]
  provisioner "ansible" {
    playbook_file   = "ansible/playbook.yaml"
    roles_path      = "ansible/roles/wazuh"
    extra_arguments = ["--extra-vars", "allow_world_readable_tmpfiles=true"]
  }
}
