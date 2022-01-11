terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.47.0"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  service_account_key_file = "./key.json"
  # or you can use: token = var.token for user account not sa
  cloud_id = "XXXXXX" #your cloud_id
  folder_id = "XXXXXX" #your folder_id
  max_retries              = 10
}



