

//Вызов модуля
module "cilium_cluster_1_export" {
    source = "../k8s-security-exporter/" # путь до модуля
    folder_id = "b1g1v8cu6isid0ms9va4" // folder-id кластера k8s yc managed-kubernetes cluster get --id <ID кластера> --format=json | jq  .folder_id

    cluster_name = "cilium-cluster-1" //bucket id выданный администратором

    log_bucket_service_account_id = "aje5p941ebl0p8qrh7tr" //id выданный администратором
    
    log_bucket_name = "nrkkrfstate" //можно подставить из конфига развертывания
    #function_service_account_id = "чч" // опциоанальный id сервисного аккаунта который вызывает функции - если не выставлен то функция вызывается от имени log_bucket_service_account_id
}


