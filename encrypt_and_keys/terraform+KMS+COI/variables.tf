//------------Служебные параметры terrafromf

variable "token" {
  description = "Yandex Cloud security OAuth token"
  default     = "/Users/mirtov8/Desktop/key.json" #generate yours by this https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID where resources will be created"
  default     = "b1gci8pu7s2seup3mpor" #yc config get folder-id
}

variable "cloud_id" {
  description = "Yandex Cloud ID where resources will be created"
  default     = "b1g3o4minpkuh10pd2rj" #yc config get cloud-id
}




