//------------Служебные параметры terrafromf

variable "token" {
  description = "Yandex Cloud security OAuth token"
  default     = "<Ваш токен>" #generate yours by this https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID where resources will be created"
  default     = "<Ваш фолдер" #yc config get folder-id
}

variable "cloud_id" {
  description = "Yandex Cloud ID where resources will be created"
  default     = "<Ваш cloud>" #yc config get cloud-id
}


//------------


variable "zones" {
  description = "Yandex Cloud default Zone for provisoned resources"
  type        = list(string)
  default     = ["ru-central1-a", "ru-central1-b"]
}

variable "network_names" {
  description = "Yandex Cloud default Zone for provisoned resources"
  type        = list(string)
  default     = ["a", "b"]
}

variable "mgmt_cidrs" {
  type        = list(string)
  default = ["192.168.0.0/24", "172.16.0.0/24"]
}

variable "app_cidrs" {
  type        = list(string)
  default = ["192.168.1.0/24", "172.17.0.0/24"]
}

variable "ext_cidrs" {
  type        = list(string)
  default = ["192.168.2.0/24", "172.18.0.0/24"]
}



