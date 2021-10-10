//Вызов модуля security-events-to-storage-exporter
module "security-events-to-storage-exporter" {
    source = "../security-events-to-storage-exporter/" # путь до модуля

    folder_id = "b1g9divt1fgrifqrkvmb" // folder-id кластера k8s yc managed-kubernetes cluster get --id <ID кластера> --format=json | jq  .folder_id

    cluster_name = "k8s-cluster-b1g9divt1fgrifqrkvmb" // имя кластера можно получить yc managed-kubernetes cluster list --format json | jq -r '.[].name'

    log_bucket_service_account_id = "ajen8r7jo0vjmt0rblpi" // можно получить yc iam service-account get --name terraform-sa-$(yc config get folder-id) --format json | jq -r '.id' 
    
    log_bucket_name = "k8s-bucket-b1g9divt1fgrifqrkvmb" // создайте бакет и подставьте

}


//Вызов модуля security-events-to-siem-importer
module "security-events-to-siem-importer" {
    source = "../security-events-to-siem-importer/" # путь до модуля

    folder_id = module.security-events-to-storage-exporter.folder_id 
    
    service_account_id = module.security-events-to-storage-exporter.service_account_id
    
    auditlog_enabled = true //отправлять k8s auditlog в elk
    
    falco_enabled = true //  установить falco и отправлять его алерты в elk

    kyverno_enabled = true // установить kyverno и отправлять его алерты в elk

    log_bucket_name = module.security-events-to-storage-exporter.log_bucket_name

    elastic_server = "https://c-c9q35pusrt22bol7cgvu.rw.mdb.yandexcloud.net" // url ELK "https://c-xxx.rw.mdb.yandexcloud.net" (можно подставить из модуля module.yc-managed-elk.elk_fqdn)

    coi_subnet_id = "e9b5bgf5s1qg7ogf2cr7" // subnet id в которой будет развернута ВМ с контейнером (обязательно включить NAT)

    elastic_pw = "b1g31gsjsn9ajhtvtea1" // пароль учетной записи ELK (можно подставить из модуля module.yc-managed-elk.elk-pass)
    
    elastic_user = "admin" // имя учетной записи ELK
}




