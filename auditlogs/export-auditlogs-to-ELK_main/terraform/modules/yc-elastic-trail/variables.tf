variable "folder_id" {
  description = "Yandex.Cloud ID каталога, где будут созданы ресурсы"
  default     = "" # yc config get folder-id
}


variable "elk_credentials" {
  description = "Пароль для аутентификации в ElasticSearch"
  default     = ""
}

variable "elk_address" {
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





