terraform {
  required_version = ">= 0.14"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.60"
    }
  }
}

provider "yandex" {
  service_account_key_file = "./key.json"
  # token = var.token
  cloud_id = var.cloud_id
  folder_id = var.folder_id
}
