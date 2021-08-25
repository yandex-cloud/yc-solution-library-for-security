# Security-events-to-siem-importer

Описание: Модуль модуль который через очередь читает логи из бакета и кладет их Elastic


### Принимает на вход: 
	- folder_id (id каталога в котором лежит кластер)
	- log_bucket_name - имя бакета куда писать лог
	- service_account_id - ( опционально) id сервисного аккаунта который будет запускать фукнцию , создавать очереди и писать в очереди
	- auditlog_enabled - включать ли поставку аулит лога ( по дефолту  true)
	- falco_enabled - включать ли поставку аудит лога 

TDB 
- параметры кластера Elastic




### Выполняет: 
	- создание статического ключа для УЗ
	- создание функции и тригера для записи логов в очереди и обогащения логов параметрами  'cloud_id','folder_id','cluster_id','cluster_url'
	TDB - поставка логов из очереди в ELASTIC

	

Пререквизиты:
1) Учетная запись под, 


### Вызов модуля
```

module "bucket_baby" {
    source = "../../../yc-solution-library-for-security/auditlogs/export-k8s-events-to-siem/security-events-to-siem-importer" # путь до модуля
    folder_id = "b1g1v8cu6isid0ms9va4" // folder-id кластера k8s yc managed-kubernetes cluster get --id <ID кластера> --format=json | jq  .folder_id


    
    log_bucket_name = "logggs" //можно подставить из конфига развертывания
    service_account_id = "<>" //id выданный администратором

}



```

