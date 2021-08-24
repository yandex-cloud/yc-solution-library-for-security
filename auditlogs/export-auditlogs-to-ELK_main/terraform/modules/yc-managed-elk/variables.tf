
variable "folder_id" {
  description = "Yandex Cloud Folder ID where resources will be created"
  default     = "" #yc config get folder-id
}

variable "cloud_id" {
  description = "Yandex Cloud ID where resources will be created"
  default     = "" #yc config get cloud-id
}

variable "subnet_ids" {
  description = "subnet_ids"
  # ["subnet-a_id", "subnet-b_id", "subnet-c_id"]
}

variable "network_id" {
  default = ""
}




