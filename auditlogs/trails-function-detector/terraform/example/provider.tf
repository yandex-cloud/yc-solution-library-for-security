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
  endpoint                 = "api.cloud-preprod.yandex.net:443" # убрать
  service_account_key_file = "./key.json"
  # or you can use: token = var.token for user account not sa
  cloud_id = "aoeij54741gkhd4hvrle"
  folder_id = "aoem46r1onav1soovie4"
  max_retries              = 10
}



