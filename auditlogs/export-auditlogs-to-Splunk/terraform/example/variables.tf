//------------Служебные параметры terrafromf

variable "token" {
  description = "Yandex Cloud security OAuth token"
  default     = "/Users/mirtov8/Desktop/key.json" #generate yours by this https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID where resources will be created"
  default     = "b1g35l8msdsaf20p5iue" #yc config get folder-id
}

variable "cloud_id" {
  description = "Yandex Cloud ID where resources will be created"
  default     = "b1g3o4minpkuh10pd2rj" #yc config get cloud-id
}

variable "splunk_token" {
}

//------------
variable "zones" {
  description = "Yandex Cloud default Zone for provisoned resources"
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
  default = ["192.168.1.0/24", "192.168.50.0/24", "192.168.70.0/24"]
}
