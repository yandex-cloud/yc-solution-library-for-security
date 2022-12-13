variable "folder_id" {
  description = "Yandex.Cloud ID каталога, где будут созданы ресурсы"
  default     = "" # yc config get folder-id
}


variable "opensearch_pass" {
  description = "Пароль для аутентификации в ElasticSearch"
  default     = ""
}

variable "opensearch_user" {
  description = "Пользователь для аутентификации в ElasticSearch"
  default     = ""
}

variable "opensearch_dashboard_address" { 
  description = "FQDN-адрес инсталляции Opensearch вида https://c-xxx.rw.mdb.yandexcloud.net" 
  default     = "" 
} 
 
variable "opensearch_node_address" { 
  description = "FQDN-адрес инсталляции Opensearch вида https://rc1a-xxx.mdb.yandexcloud.net" 
  default     = "" 
}

variable "opensearch_address" {
  description = "FQDN-адрес инсталляции ElasticSearch вида https://c-xxx.rw.mdb.yandexcloud.net"
  default     = ""
}

variable "bucket_name" {
  description = "Имя бакета, куда сохраняются логи AuditTrails"
  default     = ""
}

variable "bucket_folder" {
  description = "Имя каталога, куда сохраняются логи AuditTrails"
  default     = ""
}

variable "sa_id" {
  description = "ID сервисной учетной записи для работы с бакетом, с разрешением storage.editor"
  default     = ""
}

variable "coi_subnet_id" {
  description = "ID подсети, где будет размещен container-инстанс"
  default     = ""
}





