# security-events-to-storage-exporter
Описание: Модуль для включения логирования кластера k8s. На текущий момент он настраивает отправку audit логов в s3 и логов 


### Принимает на вход: 
	- folder_id (id каталога в котором лежит кластер)
	- cluster_name (имя кластера k8s)
	- log_bucket_service_account_id - id сервис аккаунта который может писать в бакет
	- log_bucket_name - имя бакета куда писать лог
	- function_service_account_id - ( опционально) id сервисного аккаунта который будет запускать фукнцию , если не указан то используется log_bucket_service_account_id
  
### Выполняет: 
	- создание статического ключа для УЗ
	- создание функции и тригера для записи логов кластера в s3
	- установку falco и настроенного falcosidekick, который отправит логи в s3
	- установку OPA Gatekeeper

### TBD

	- настройку библиотек OPA Gatekeeper 

Пререквизиты:
1) Учетная запись под, которой вызывается сам модуль (должна обладать правами на создание кластера k8s и назначением права serverless.function на sa)

Пример вызова модуля (находится рядом в папке):



### Вызов модуля
```
module "cilium_cluster_1_export" {
    source = "../k8s-security-exporter/" # путь до модуля
    folder_id = "sadsada" // folder-id кластера k8s yc managed-kubernetes cluster get --name=<имя кластера> --format=json | jq  .folder_id

    cluster_name = "cilium-cluster-1" //bucket id выданный администратором

    log_bucket_service_account_id = "dsadsadsa" //id выданный администратором
    
    log_bucket_name = "dasdas" //можно подставить из конфига развертывания
}

```

