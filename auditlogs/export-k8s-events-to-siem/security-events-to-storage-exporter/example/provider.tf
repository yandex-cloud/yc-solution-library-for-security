terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}
/*
provider "yandex" {
  service_account_key_file = "./key.json"
  #or you can use: token = var.token for user account not sa
  cloud_id = "b1g3o4minpkuh10pd2rj"
  folder_id = "b1g30dckl1ctvpjqdudf"
}

*/
