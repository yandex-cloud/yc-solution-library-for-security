
terraform {
  required_version = ">= 0.14"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.5"
    }
  }
}

provider "yandex" {
  service_account_key_file = var.token
  # or you can use: token = var.token for sa account 
  cloud_id = var.cloud_id
  folder_id = var.folder_id
}