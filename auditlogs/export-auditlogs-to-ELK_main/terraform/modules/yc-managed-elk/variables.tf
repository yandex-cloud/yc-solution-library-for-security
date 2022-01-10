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

variable "elk_edition" {
  description = "Редакция установки ELK (basic, gold, platinum)"
  default     =  "gold"
}

variable "elk_datanode_preset" {
  # see https://cloud.yandex.com/ru-kz/docs/managed-elasticsearch/concepts/instance-types#available-flavors
  description = "Размер ВМ для data узла" 
  default     = "s2.medium"
}

variable "elk_datanode_disk_size" {
  description = "Размер диска data узла, в GB"
  default     = 1000
}

variable "elk_public_ip" {
  description = "Назначать публичный IP адрес"
  default     = false
}

variable "elk_name" {
  description = "Имя кластера ElasticSearch"
  default     = "elk"
}