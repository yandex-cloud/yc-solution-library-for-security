
variable "token" {
  description = "Yandex Cloud security OAuth token"
  default     = "/Users/mirtov8/Documents/key.json" #generate yours by this https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID where resources will be created"
  default     = "b1g35l8msdsaf20p5iue" #yc config get folder-id
}

variable "cloud_id" {
  description = "Yandex Cloud ID where resources will be created"
  default     = "b1gkmtuljp4d2k3g5aph" #yc config get cloud-id
}

//----------------------------------------------------------------

variable "all-access-users" {
  description = ""
  default = ["federatedUser:ajesnkfkc77lbh50isvg", "federatedUser:ajeurmedn87ekpuc4e08"]

}

variable "read-only-sa" {
  description = ""
  default = ["serviceAccount:ajeph8f8d7pp4j0cbprj", "serviceAccount:aje066sl8m1e7ci508bl"]

}

variable "write-only-sa" {
  description = "sa"
  default = ["serviceAccount:ajem3ef72rr9hhe5kso6", "serviceAccount:aje1ngf44k7nceombinn"]

}