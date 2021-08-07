variable "token" {
  description = "Yandex Cloud security OAuth token"
  default     = "nope" #generate yours by this https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token
}

variable "folder_id" {
  description = "infra folder for main resources"
  default     = "enter your folder id"
}

variable "cloud_id" {
  description = "Yandex Cloud ID where resources will be created"
  default     = "there is cloud id"
}

variable "public_key_path" {
  description = "Path to ssh public key, which would be used to access workers"
  default     = "~/.ssh/id_rsa.pub"
}

variable "dev_folder_id" {
  description = "folder for dev environment"
  default     = "enter your dev folder id"
}

variable "stage_folder_id" {
  description = "folder for stage environment"
  default     = "enter your stage folder id"
}

variable "prod_folder_id" {
  description = "folder for stage environment"
  default     = "enter your stage folder id"
}

variable "bastion_whitelist_ip" {
  type    = list(string)
  default = ["1.1.1.1/32"]
}
