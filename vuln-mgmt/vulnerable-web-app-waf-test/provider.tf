terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  service_account_key_file = var.token
  #or you can use: token = var.token for user account not sa
  cloud_id = var.cloud_id
  folder_id = var.folder_id
}