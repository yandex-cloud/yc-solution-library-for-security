variable "token" {
  description = "Yandex Cloud security OAuth token"
  default     = "/Users/mirtov8/Documents/terraform-play/tf-dvwa/key.json" #generate yours by this https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID where resources will be created"
  default     = "" #put yours id of folder
}

variable "cloud_id" {
  description = "Yandex Cloud ID where resources will be created"
  default     = "" #put yours id of cloud
}

