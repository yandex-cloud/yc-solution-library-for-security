//-------------Служебные параметры terrafromf

variable "token" {
  description = "Yandex Cloud security OAuth token"
  default     = "" #generate yours by this https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID where resources will be created"
  default     = "" #yc config get folder-id
}

variable "cloud_id" {
  description = "Yandex Cloud ID where resources will be created"
  default     = "" #yc config get cloud-id
}

variable "vpc_id" {
  description = "Yandex Cloud ID where resources will be created"
  default     = "" #yc vpc network list --format=json | jq '.[].id'
}

variable "extlb_id" {
  description = "Yandex Cloud ID where resources will be created"
  default     = "b7r0fumb6qsha7mfmvsb" #yc load-balancer network-load-balancer list --format=json | jq '.[].id'
}
//terraform import yandex_lb_network_load_balancer.ext-lb ${yc load-balancer network-load-balancer list --format=json | jq '.[].id' | sed 's/"//g'} (первым делом выполнить команду) 

variable "app_target_group_id" {
  description = "Yandex Cloud ID where resources will be created"
  default     = "" #yc load-balancer target-group list --format=json | jq '.[].id'
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

variable "ext_cidrs" {
  type        = list(string)
  default = ["192.168.2.0/24", "172.18.0.0/24"]
}

variable "mgmt_cidrs" {
  type        = list(string)
  default = ["192.168.0.0/24", "172.16.0.0/24"]
}

