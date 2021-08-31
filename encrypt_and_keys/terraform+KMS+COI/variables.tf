//------------Служебные параметры terrafromf

variable "token" {
  description = "Yandex Cloud security OAuth token"
  default     = "key.json" #generate yours by this https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID where resources will be created"
  default     = "xxxxxx" #yc config get folder-id
}

variable "cloud_id" {
  description = "Yandex Cloud ID where resources will be created"
  default     = "xxxxxx" #yc config get cloud-id
}