# ==================================
# Terraform & Provider Configuration
# ==================================

terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  #service_account_key_file = ""
  #token     = ""
  #cloud_id  = ""
  #folder_id = ""
  zone      = "ru-central1-a"
}
