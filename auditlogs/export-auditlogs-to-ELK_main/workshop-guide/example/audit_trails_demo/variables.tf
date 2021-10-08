variable "token" {
  description = "Yandex.Cloud security OAuth token либо ключ сервисного аккаунта"
  default     = "key.json" # generate yours by this https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token
}

variable "folder_id" {
  description = "Yandex.Cloud Folder ID where resources will be created"
  default     = "b1g31gsjsn9ajhtvtea1" # yc config get folder-id
}

variable "cloud_id" {
  description = "Yandex.Cloud ID where resources will be created"
  default     = "b1gq9j4sbpge1hdasvtp" # yc config get cloud-id
}

