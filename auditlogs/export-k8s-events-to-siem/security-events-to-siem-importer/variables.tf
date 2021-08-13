
variable "folder_id" {

}



variable "log_bucket_name" {

}

variable "auditlogsprefix" {
    default = "AUDIT/"
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

variable "falcoprefix" {
    default = "falco/"
}



variable "service_account_id" {
 #functions.invoker, storage.editor, ymq.editor
}
