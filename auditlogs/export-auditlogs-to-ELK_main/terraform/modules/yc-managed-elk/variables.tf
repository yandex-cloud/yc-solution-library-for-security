variable "folder_id" {
  description = "Yandex.Cloud ID каталога"
  default     = "" # yc config get folder-id
}

variable "cloud_id" {
  description = "Yandex.Cloud ID облака"
  default     = "" # yc config get cloud-id
}

variable "subnet_ids" {
  description = "ID подсетей для размещения хостов ElasticSearch" 
  default     = ""
  # ["subnet-a_id", "subnet-b_id", "subnet-c_id"]
}

variable "network_id" {
  description = "ID сети для размещения хостов ElasticSearch" 
  default     = ""
}