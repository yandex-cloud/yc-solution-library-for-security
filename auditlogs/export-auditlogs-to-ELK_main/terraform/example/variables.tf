variable "token" {
  description = "Yandex.Cloud security OAuth token либо ключ сервисного аккаунта"
  default     = "key.json" # generate yours by this https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token
}

variable "folder_id" {
  description = "Yandex.Cloud Folder ID where resources will be created"
  default     = "xxxxxx" # yc config get folder-id
}

variable "cloud_id" {
  description = "Yandex.Cloud ID where resources will be created"
  default     = "xxxxxx" # yc config get cloud-id
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

variable "var_elk_node_preset" {
  type        = list(string)
  default     = "s2.micro"
}

variable "var_elk_node_disk_size" {
  type        = list(string)
  default     = "60"
}
