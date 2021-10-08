variable "token" {
  description = "Yandex.Cloud security OAuth token либо ключ сервисного аккаунта"
  default     = "key.json" # generate yours by this https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token
}

variable "folder_id" {
  description = "Yandex.Cloud Folder ID where resources will be created"
  default     = "b1g88oud6hi0r8j4mv71" # yc config get folder-id
}

variable "cloud_id" {
  description = "Yandex.Cloud ID where resources will be created"
  default     = "b1gq9j4sbpge1hdasvtp" # yc config get cloud-id
}

variable "zones" {
  description = "Yandex.Cloud default Zone for provisoned resources"
  type        = list(string)
  default     = ["ru-central1-a", "ru-central1-b", "ru-central1-c"]
}

variable "network_names" {
  description = "Yandex Cloud default Zone for provisoned resources"
  type        = list(string)
  default     = ["a", "b", "c"]
}

variable "app_cidrs" {
  type        = list(string)
  default     = ["192.168.1.0/24", "192.168.50.0/24", "192.168.70.0/24"]
}

variable "elk_edition" {
  description = "Редакция установки ELK (basic, gold, platinum)"
  default     =  "gold"
}

variable "elk_datanode_preset" {
  # see https://cloud.yandex.com/ru-kz/docs/managed-elasticsearch/concepts/instance-types#available-flavors
  description = "Размер ВМ для data узла" 
  default     = "s2.small"
}

variable "elk_datanode_disk_size" {
  description = "Размер диска data узла, в GB"
  default     = 50
}