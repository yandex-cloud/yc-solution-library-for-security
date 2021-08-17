provider "yandex" {
  service_account_key_file = "key.json"
  cloud_id                 = "b1g3o4minpkuh10pd2rj"
  folder_id                = var.folder_id
  zone                     = "ru-central1-a"
}