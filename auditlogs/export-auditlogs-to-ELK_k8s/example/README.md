## Тестовый скрипт terraform 


1) Заполните поля файла main.tf
2) Запустите:

```
terraform init
terraform apply
```

Пример вызова модулей:
// Вызов модуля security-events-to-storage-exporter
module "security-events-to-storage-exporter" {
    source = "../security-events-to-storage-exporter/" # путь до модуля

    folder_id = "xxxxxx" // folder-id кластера k8s yc managed-kubernetes cluster get --id <ID кластера> --format=json | jq  .folder_id

    cluster_name = "k8s-example" // имя кластера

    log_bucket_service_account_id = "xxxxxx" // id sa (должен обладать ролями: ymq.admin, write to bucket)
    
    log_bucket_name = "k8s-bucket" // можно подставить из конфига развертывания
    #function_service_account_id = "чч" // опциоанальный id сервисного аккаунта который вызывает функции - если не выставлен то функция вызывается от имени log_bucket_service_account_id
}


// Вызов модуля security-events-to-siem-importer
module "security-events-to-siem-importer" {
    source = "../security-events-to-siem-importer/" # путь до модуля

    folder_id = module.security-events-to-storage-exporter.folder_id 
    
    service_account_id = module.security-events-to-storage-exporter.service_account_id
    
    auditlog_enabled = true //отправлять k8s auditlog в elk
    
    falco_enabled = true // отправлять алерты falco в elk 

    log_bucket_name = module.security-events-to-storage-exporter.log_bucket_name

    elastic_server = "https://c-xxx.rw.mdb.yandexcloud.net" // url ELK "https://c-xxx.rw.mdb.yandexcloud.net" (можно подставить из модуля module.yc-managed-elk.elk_fqdn)

    coi_subnet_id = "xxxxxx" // subnet id в которой будет развернута ВМ с контейнером (обязательно включить NAT)

    elastic_pw = "P@ssw0rd" // пароль учетной записи ELK (можно подставить из модуля module.yc-managed-elk.elk-pass)
    
    elastic_user = "admin" // имя учетной записи ELK
}
