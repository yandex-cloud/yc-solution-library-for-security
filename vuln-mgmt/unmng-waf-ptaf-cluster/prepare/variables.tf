//------------Служебные параметры terrafromf

variable "token" {
  description = "Yandex Cloud security OAuth token"
  default     = "AQAAAAAH6dWxAATuwV69XK6GAUwpkuEVDVDmqgw" #generate yours by this https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID where resources will be created"
  default     = "b1ghen4foi7mbm59jb7f" #yc config get folder-id
}

variable "cloud_id" {
  description = "Yandex Cloud ID where resources will be created"
  default     = "b1gkmtuljp4d2k3g5aph" #yc config get cloud-id
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



variable "app_cidrs" {
  type        = list(string)
  default = ["192.168.1.0/24", "172.17.0.0/24"]
}




