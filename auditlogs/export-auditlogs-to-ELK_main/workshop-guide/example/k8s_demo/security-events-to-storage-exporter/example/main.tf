// Вызов модуля
module "cilium_cluster_1_export" {
    source = "../../security-events-to-storage-exporter/" # путь до модуля
    folder_id = "xxxxxx" // folder-id кластера k8s yc managed-kubernetes cluster get --id <ID кластера> --format=json | jq  .folder_id

    cluster_name = "cilium-cluster-1" // имя кластера

    log_bucket_service_account_id = "xxxxxx" // id выданный администратором
    
    log_bucket_name = "xxxxxx" // можно подставить из конфига развертывания
    # function_service_account_id = "чч" // опциоанальный id сервисного аккаунта который вызывает функции - если не выставлен то функция вызывается от имени log_bucket_service_account_id
}


