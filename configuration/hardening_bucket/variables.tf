
variable "token" {
  description = "Yandex Cloud security OAuth token"
  default     = "key.json" # generate yours: https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID where resources will be created"
  default     = "xxxxxx" #yc config get folder-id
}

variable "cloud_id" {
  description = "Yandex Cloud ID where resources will be created"
  default     = "xxxxxx" #yc config get cloud-id
}

// ----------------------------------------------------------------

variable "all-access-users" {
  description = ""
  default = ["federatedUser:ajesnkfkxxxxxxxxxxxx", "federatedUser:ajeurmedxxxxxxxxxxxx"]
}

variable "read-only-sa" {
  description = ""
  default = ["serviceAccount:ajeph8f8xxxxxxxxxxxx", "serviceAccount:aje066slxxxxxxxxxxxx"]
}

variable "write-only-sa" {
  description = "sa"
  default = ["serviceAccount:ajem3ef7xxxxxxxxxxxx", "serviceAccount:aje1ngf4xxxxxxxxxxxx"]
}