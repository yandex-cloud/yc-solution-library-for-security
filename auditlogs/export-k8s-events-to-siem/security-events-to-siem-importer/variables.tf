variable "folder_id" {

}

variable "log_bucket_name" {

}

variable "service_account_id" {
 #functions.invoker, storage.editor, ymq.editor
}

variable "auditlog_enabled" {
    default = true
}

variable "auditlogs_prefix" {
    default = "AUDIT/"
}

variable "falco_enabled" {
    default = true
}

variable "falco_prefix" {
    default = "FALCO/"
}

variable "elastic_pw" {

}

variable "elastic_user" {

}

variable "elastic_server" {
    default = "https://c-xxx.rw.mdb.yandexcloud.net"
}

variable "coi_subnet_id" {
  description = "subnet id for COI instance"
  default = ""
}

/*
https://storage.yandexcloud.net/etalon-bucket-elk-k8s/
AUDIT
/
b1g3o4minpkuh10pd2rj
/
b1g1v8cu6isid0ms9va4
/
cat4g7pouq1bbhhgjii9
/
2021-08-13-10:30:10-AiZrC
/
*/