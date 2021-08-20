
variable "folder_id" {
  description = "Yandex Cloud Folder ID where resources will be created"
  default     = "" #yc config get folder-id
}


variable "elk_credentials" {
  default     = "" #yc config get cloud-id
}

variable "elk_address" {
  default     = "" #yc config get cloud-id
}

variable "bucket_name" {
  default = ""
}

variable "bucket_folder" {
  default = ""
}

variable "sa_id" {
  description = "subnet_ids"
  default = ""
}

variable "coi_subnet_id" {
  description = "subnet_id"
  default = ""
}





