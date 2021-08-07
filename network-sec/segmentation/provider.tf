provider "yandex" {
  token = var.token
  cloud_id = var.cloud_id
  folder_id = var.folder_id
}

module "sa_and_key" {
source = "./sa_and_key"
folder_id = var.folder_id
}
