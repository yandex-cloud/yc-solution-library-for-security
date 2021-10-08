terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  service_account_key_file = "./key.json"
  # or you can use: token = var.token for user account not sa
  cloud_id = "b1gq9j4sbpge1hdasvtp" // можно получить командой yc config get cloud-id  
  folder_id = "b1g9divt1fgrifqrkvmb" // можно получить командой yc config get folder-id  
}

