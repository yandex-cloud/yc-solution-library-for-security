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
  service_account_key_file = "./sa-key.json"
  #token     = ""
  cloud_id  = var.ORG_ADMIN_CLOUD_ID
  #folder_id = ""
}
