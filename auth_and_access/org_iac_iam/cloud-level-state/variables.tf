variable "CLOUD_ID" {
  description = "cloud_id of your cloud"
  type    = string
  default = ""
}

variable "FOLDER_ID" {
  description = "folder id of first folder"
  type    = string
  default = ""
}

variable "zones" {
  description = "Yandex.Cloud default Zone for provisoned resources"
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
  default     = ["192.168.1.0/24", "192.168.50.0/24", "192.168.70.0/24"]
}

variable "app_cidrs2" {
  type        = list(string)
  default     = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24"]
}

variable "app_cidrs3" {
  type        = list(string)
  default     = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
}

variable "org_id" {
  description = "organization_id"
  type        = string
  default     = ""
}





