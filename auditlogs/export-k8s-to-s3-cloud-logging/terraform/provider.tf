terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  # service_account_key_file  = var.provider_key_file
  cloud_id                  = var.cloud_id
  folder_id                 = var.folder_id
  zone                      = var.zone
  token                     = "token"
}